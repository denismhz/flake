
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
        ../../packages/audiolm-pytorch
        ../../packages/ema-pytorch
        ../../packages/local-attention
        ../../packages/pytorch-seed
        ../../packages/vector-quantize-pytorch
      ])
    ];

    python3Variants = {
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    src = inputs.bark-gui-src;
    mkbark-guiVariant = args: pkgs.callPackage ./package.nix ({ inherit src;  } // args);
  in {
    packages = {
      bark-gui-nvidia = mkbark-guiVariant {
        python3Packages = python3Variants.nvidia;
      };
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.bark-gui.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    #bark-gui = ./nixos;
    #invokeai-nvidia = {
    #  imports = [
    #    config.flake.nixosModules.invokeai
    #    (packageModule "bark-gui-nvidia")
    #  ];
    #};
  };
}
