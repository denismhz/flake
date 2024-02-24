{
  config,
  inputs,
  lib,
  withSystem,
  ...
}: {
  perSystem = {
    config,
    pkgs,
    system,
    ...
  }: let
    src = inputs.comfyui-src;

    stable-pkgs = import inputs.nixpkgs-stable {
      allowUnfree = true;
      cudaSupport = true;
      inherit system;
      inherit overlays;
    };
    overlays = [
      (
        final: prev: {
          final.python310 = prev.python310.override {
            enableOptimizations = true;
            reproducibleBuild = false;
            self = final.python310;
            buildInputs = [final.ffmpeg-full];
          };
          pythonPackagesExtensions =
            prev.pythonPackagesExtensions
            ++ [
              (
                python-final: python-prev: {
                  torch = python-prev.torch.override {
                    rocmSupport = false;
                    cudaSupport = true;
                  };
                }
              )
            ];
        }
      )
    ];

    mkComfyUIVariant = args:
      stable-pkgs.python310Packages.callPackage ./package.nix ({
          inherit src;
        }
        // args);
  in {
    packages = {
      comfyui-nvidia = mkComfyUIVariant {};
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: {pkgs, ...}: {
      services.comfyui.package = withSystem pkgs.system (
        {config, ...}: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    comfyui = ./nixos;
    comfyui-nvidia = {
      imports = [
        config.flake.nixosModules.comfyui
        (packageModule "comfyui-nvidia")
      ];
    };
  };
}
