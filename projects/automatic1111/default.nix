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
        
        ../../packages/discord-webhook
        ../../packages/deforum
        ../../packages/ultralytics
        ../../packages/rich
        ../../packages/k_diffusion
        ../../packages/openclip
        ../../packages/safetensors
        ../../packages/easing-functions
        ../../packages/dynamicprompts
        ../../packages/controlnet-aux
        ../../packages/fastapi
        ../../packages/fastapi-events
        ../../packages/fastapi-socketio
        ../../packages/pytorch-lightning
        ../../packages/starlette
        ../../packages/compel
        ../../packages/taming-transformers-rom1504
        ../../packages/albumentations
        ../../packages/qudida
        ../../packages/gfpgan
        ../../packages/basicsr
        ../../packages/facexlib
        ../../packages/realesrgan
        ../../packages/codeformer
        ../../packages/clipseg
        ../../packages/kornia
        ../../packages/picklescan
        ../../packages/diffusers
        ../../packages/pypatchmatch
        ../../packages/torch-fidelity
        ../../packages/resize-right
        ../../packages/torchdiffeq
        ../../packages/accelerate
        ../../packages/clip-anytorch
        ../../packages/clean-fid
        ../../packages/getpass-asterisk
        ../../packages/mediapipe
        ../../packages/python-engineio
        ../../packages/lpips
        ../../packages/blip
        ../../packages/gradio
        ../../packages/gradio-client
        ../../packages/analytics-python
        ../../packages/tomesd
        ../../packages/blendmodes
        ../../packages/xformers
        ../../packages/zipunicode
      ])
      (final: prev: lib.mapAttrs
        (_: pkg: pkg.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
          pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
        }))
        {
          inherit (prev)
            albumentations
            qudida
            gfpgan
            basicsr
            facexlib
            realesrgan
            clipseg
          ;
        }
      )
    ];

    python3Variants = {
      nvidia = l.overlays.applyOverlays pkgs.python3Packages (commonOverlays ++ [
        overlays.python-torchCuda
      ]);
    };

    src = inputs.a1111-src;
    mkAutomatic1111Variant = args: pkgs.callPackage ./package.nix ({ inherit src; sd-src = inputs.sd-src; sgm-src = inputs.sgm-src; } // args);
  in {
    packages = {
      a1111-nvidia = mkAutomatic1111Variant {
        python3Packages = python3Variants.nvidia;
      };
    };
  };

  flake.nixosModules = let
    packageModule = pkgAttrName: { pkgs, ... }: {
      services.a1111.package = withSystem pkgs.system (
        { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
      );
    };
  in {
    a1111 = ./nixos;
    invokeai-nvidia = {
      imports = [
        config.flake.nixosModules.invokeai
        (packageModule "a1111-nvidia")
      ];
    };
  };
}
