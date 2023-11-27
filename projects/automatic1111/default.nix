{ config, inputs, lib, withSystem, ... }:

let
  l = lib // config.flake.lib;
  inherit (config.flake) overlays;
in

{
  perSystem = { config, pkgs, system, ... }:
    let
      commonOverlays = [
        #need pillow < 10.0.0 for scripts like x,y,z plot to work
        #cant i do like only for this for invoke other version?
        (
          final: prev: {
            pillow = pkgs.python3.pkgs.callPackage ../../packages/pillow { };
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (
                python-final: python-prev: {
                  pillow = python-final.callPackage ../../packages/pillow { };
                }
              )
            ];
          }
        )
        overlays.python-fixPackages
        (l.overlays.callManyPackages [
          ../../packages/analytics-python
          ../../packages/basicsr
          ../../packages/blendmodes
          ../../packages/blip
          ../../packages/codeformer
          ../../packages/facexlib
          ../../packages/gfpgan
          ../../packages/gradio
          ../../packages/gradio-client
          ../../packages/k_diffusion
          ../../packages/lpips
          ../../packages/openclip
          ../../packages/pillow
          ../../packages/pytorch-lightning
          ../../packages/realesrgan
          ../../packages/taming-transformers-rom1504
          ../../packages/tomesd
          ../../packages/torch-fidelity
          ../../packages/torch-grammar
          ../../packages/xformers
        ])
        (final: prev: lib.mapAttrs
          (_: pkg: pkg.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [ final.pythonRelaxDepsHook ];
            pythonRemoveDeps = [ "opencv-python-headless" "opencv-python" "tb-nightly" "clip" ];
          }
          ))
          {
            inherit (prev)
              gfpgan
              basicsr
              facexlib
              realesrgan
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
    in
    {
      packages = {
        a1111-nvidia = mkAutomatic1111Variant {
          python3Packages = python3Variants.nvidia;
        };
      };
    };

  flake.nixosModules =
    let
      packageModule = pkgAttrName: { pkgs, ... }: {
        services.a1111.package = withSystem pkgs.system (
          { config, ... }: lib.mkOptionDefault config.packages.${pkgAttrName}
        );
      };
    in
    {
      a1111 = ./nixos;
      a1111-nvidia = {
        imports = [
          config.flake.nixosModules.a1111
          (packageModule "a1111-nvidia")
        ];
      };
    };
}
