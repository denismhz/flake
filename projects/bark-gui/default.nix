{ config, inputs, lib, withSystem, ... }:
{
  perSystem = { config, pkgs, ... }:
    let
      src = inputs.bark-gui-src;
      overlays = [
        (
          final: prev: {
            final.python310 = prev.python310.override {
              enableOptimizations = true;
              reproducibleBuild = false;
              self = final.python310;
              buildInputs = [ final.ffmpeg-full ];
            };
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (
                python-final: python-prev: {
                  pytorch-seed = python-final.callPackage ../../Packages/pytorch-seed { };
                  audiolm-pytorch = python-final.callPackage ../../Packages/audiolm-pytorch { };
                  vector-quantize-pytorch = python-final.callPackage ../../Packages/vector-quantize-pytorch { };
                  local-attention = python-final.callPackage ../../Packages/local-attention { };
                  ema-pytorch = python-final.callPackage ../../Packages/ema-pytorch { };

                  openai-triton = python-prev.openai-triton-bin;
                  torch = python-prev.torch-bin;
                  torchaudio = python-prev.torchaudio-bin;

                  #bark-gui = python-final.callPackage ../../Packages/bark-gui.nix { };
                }
              )
            ];
          }
        )
      ];
      mkbark-guiVariant = args: pkgs.callPackage ./package.nix ({ inherit src; } // args);
    in
    {
      packages = {
        bark-gui = mkbark-guiVariant {
          inherit overlays;
        };
      };
    };
}
