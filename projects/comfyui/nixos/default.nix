{
  config,
  lib,
  ...
}: let
  inherit
    (lib)
    mkIf
    mkOption
    mkEnableOption
    mkRenamedOptionModule
    types
    escapeShellArgs
    flatten
    getExe
    mapAttrsToList
    isBool
    isFloat
    isInt
    isList
    isString
    floatToString
    optionalString
    ;

  cfg = config.services.comfyui;
in {
  imports = map ({
    old,
    new ? old,
  }:
    mkRenamedOptionModule ["services" "comfyui" old] ["services" "comfyui" "settings" new]) [
    {old = "host";}
    {old = "port";}
    {
      old = "dataDir";
      new = "root";
    }
    {old = "precision";}
  ];
  options.services.comfyui = {
    enable = mkEnableOption "ComfyUI for Stable Diffusion";

    package = mkOption {
      description = "Which ComfyUI package to use.";
      type = types.package;
    };

    user = mkOption {
      description = "Which user to run ComfyUI as.";
      default = "comfyui";
      type = types.str;
    };

    group = mkOption {
      description = "Which group to run ComfyUI as.";
      default = "comfyui";
      type = types.str;
    };

    extraArgs = mkOption {
      description = "Additional raw command line arguments.";
      default = [];
      type = with types; listOf str;
    };
  };

  config = let
    cliArgs = cfg.extraArgs;
  in
    mkIf cfg.enable {
      users.users = mkIf (cfg.user == "comfyui") {
        comfyui = {
          isSystemUser = true;
          inherit (cfg) group;
        };
      };
      users.groups = mkIf (cfg.group == "comfyui") {
        comfyui = {};
      };
      systemd.services.a1111 = {
        after = ["network.target"];
        wantedBy = ["multi-user.target"];
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
        "d '${cfg.settings.data-dir}/' 0755 ${cfg.user} ${cfg.group} - -"
        "d '${cfg.settings.data-dir}/configs' 0755 ${cfg.user} ${cfg.group} - -"
        "d '${cfg.settings.data-dir}/.home' 0750 ${cfg.user} ${cfg.group} - -"
      ];
    };
}
