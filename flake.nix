{
  nixConfig = {
    extra-substituters = [ "https://ai.cachix.org" ];
    extra-trusted-public-keys = [ "ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc=" ];
  };

  description = "A Nix Flake that makes AI reproducible and easy to run";

  inputs = {
    comfyui-src = {
      url = github:comfyanonymous/ComfyUI;
      flake = false;
    };
    nixpkgs-stable = {
      url = github:NixOS/nixpkgs/nixos-23.05;
    };
    bark-gui-src = {
      url = "github:C0untFloyd/bark-gui";
      flake = false;
    };
    kohya_ss-src = {
      url = "github:bmaltais/kohya_ss";
      flake = false;
    };
    sgm-src = {
      url = "github:Stability-AI/generative-models";
      flake = false;
    };
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    a1111-src = {
      url = "github:automatic1111/stable-diffusion-webui";
      flake = false;
    };
    sd-src = {
      url = "github:Stability-AI/stablediffusion";
      flake = false;
    };
    invokeai-src = {
      url = "github:invoke-ai/InvokeAI/v3.3.0post3";
      flake = false;
    };
    textgen-src = {
      url = "github:oobabooga/text-generation-webui/v1.7";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { flake-parts, invokeai-src, hercules-ci-effects, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      perSystem = { system, ... }: {
        #  _module.args.pkgs = import inputs.nixpkgs { config.allowUnfree = true; inherit system; config.cudaSupport = true; };
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          /*overlays = [
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
                      torch = python-prev.torch-bin;
                    }
                  )
                ];
              }
            )
          ];*/
          config = { allowUnfree = true; cudaSupport = true; };
        };
        legacyPackages = {
          koboldai = builtins.throw ''
            koboldai has been dropped from nixified.ai due to lack of upstream development,
            try textgen instead which is better maintained. If you would like to use the last
            available version of koboldai with nixified.ai, then run:

            nix run github:nixified.ai/flake/0c58f8cba3fb42c54f2a7bf9bd45ee4cbc9f2477#koboldai
          '';
        };
      };
      systems = [
        "x86_64-linux"
      ];
      debug = true;
      imports = [
        hercules-ci-effects.flakeModule
        #        ./modules/nixpkgs-config
        ./overlays
        ./projects/comfyui
        ./projects/automatic1111
        ./projects/invokeai
        ./projects/textgen
        ./projects/kohya_ss
        ./projects/bark-gui
        ./website
      ];
    };
}
