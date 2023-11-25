{ config, inputs, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, ... }: let
    commonOverlays = [
      overlays.python-fixPackages
      (l.overlays.callManyPackages [
      ])
    ];

    python3Variants = {
      amd = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchRocm
      ]);
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    src = inputs.kohya_ss-src;

    mkkohya_ssVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
  in {
    packages = {
      kohya_ss-nvidia = mkkohya_ssVariant {
        python3Packages = python3Variants.nvidia;
      };
    };
    legacyPackages = {
      kohya_ss-amd = throw ''
        AMD not done yet.
      '';
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.kohya_ss.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    kohya_ss = ./nixos;
    kohya_ss-amd = {
      imports = [
        config.flake.nixosModules.invokeai
        (packageModule "kohya_ss-amd")
      ];
    };
    kohya_ss-nvidia = {
      imports = [
        config.flake.nixosModules.invokeai
        (packageModule "kohya_ss-nvidia")
      ];
    };
  };
}
