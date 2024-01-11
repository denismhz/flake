{ config, inputs, lib, withSystem, ... }:
{
  perSystem = { config, pkgs, system, ... }:
    let
      src = inputs.comfyui-src;

      stable-pkgs = import inputs.nixpkgs-stable {
        allowUnfree = true;
        cudaSupport = true;
        inherit system;
      };

      mkComfyUIVariant = args: pkgs.python310Packages.callPackage ./package.nix ({
        inherit src;
      } // args);
    in
    {
      packages = {
        comfyui-nvidia = mkComfyUIVariant { };
      };
    };

  #flake.nixosModules =
  /*  let
    packageModule = pkgAttrName: { pkgs, ... }: {
    services.comfyui.package = withSystem pkgs.system (
    { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
    );
    };
    in
    {
    comfyui = ./nixos;
    comfyui-nvidia = {
    imports = [
    config.flake.nixosModules.a1111
    (packageModule "comfyui-nvidia")
    ];
    };
    };*/
}
