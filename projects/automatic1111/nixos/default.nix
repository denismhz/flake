{ config, lib, ... }:

let
  inherit (lib)
    mkIf mkOption mkEnableOption mkRenamedOptionModule types
    escapeShellArgs flatten getExe mapAttrsToList
    isBool isFloat isInt isList isString
    floatToString optionalString
  ;

  cfg = config.services.a1111;
in

{
  imports = map ({ old, new ? old }: mkRenamedOptionModule [ "services" "a1111" old ] [ "services" "a1111" "settings" new ]) [
    { old = "host"; }
    { old = "port"; }
    { old = "dataDir"; new = "root"; }
    { old = "precision"; }
  ];
  options.services.a1111 = {
    enable = mkEnableOption "Automatic1111 UI for Stable Diffusion";

    package = mkOption {
      description = "Which Automatic1111 package to use.";
      type = types.package;
    };

    user = mkOption {
      description = "Which user to run A1111 as.";
      default = "a1111";
      type = types.str;
    };

    group = mkOption {
      description = "Which group to run A1111 as.";
      default = "a1111";
      type = types.str;
    };

    settings = mkOption {
      description = "Structured command line arguments.";
      default = { };
      type = types.submodule {
        freeformType = with types; let
          atom = nullOr (oneOf [
            bool
            str
            int
            float
          ]);
        in attrsOf (either atom (listOf atom));
        options = {
          #listen = mkOption {
          #  description = "Launch gradio with 0.0.0.0 as server name, allowing to respond to network requests.";
          #  default = false;
          #  type = types.bool;
          #};

          port = mkOption {
            description = "Launch gradio with given server port, you need root/admin rights for ports < 1024; defaults to 7860 if available.";
            default = 7860;
            type = types.port;
          };

          data-dir = mkOption {
            description = "Where to store A1111's state.";
            default = "/var/lib/a1111";
            type = types.path;
          };

          ckpt-dir = mkOption {
            description = "Path to A1111's SD models.";
            default = "/var/lib/models/ckpt";
            type = types.path;
          };
        };
      };
    };

    extraArgs = mkOption {
      description = "Additional raw command line arguments.";
      default = [];
      type = with types; listOf str;
    };
  };

  config = let

    cliArgs = (flatten (mapAttrsToList (n: v:
      if v == null then []      
      #else if isBool v then [ "--${optionalString (!v) "no-"}${n}" ]
      else if isInt v then [ "--${n}" "${toString v}" ]
      else if isFloat v then [ "--${n}" "${floatToString v}" ]
      else if isString v then ["--${n}" v ]
      else if isList v then [ "--${n}" (toString v) ]
      else throw "Unhandled type for setting \"${n}\""
    ) cfg.settings)) ++ cfg.extraArgs;

  in mkIf cfg.enable {
    users.users = mkIf (cfg.user == "a1111") {
      a1111 = {
        isSystemUser = true;
        inherit (cfg) group;
      };
    };
    users.groups = mkIf (cfg.group == "a1111") {
      a1111 = {};
    };
    systemd.services.a1111 = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        HOME = "${cfg.settings.data-dir}/.home";
        COMMANDLINE_ARGS = escapeShellArgs cliArgs;
        NIXIFIED_AI_NONINTERACTIVE = "1";
      };
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${getExe cfg.package}";
        PrivateTmp = true;
      };
    };
    systemd.tmpfiles.rules = [
      "d '${cfg.settings.data-dir}/*' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.settings.data-dir}/configs' 0755 ${cfg.user} ${cfg.group} - -"
      "d '${cfg.settings.data-dir}/.home' 0750 ${cfg.user} ${cfg.group} - -"
    ];
  };
}
