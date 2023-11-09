{ python3Packages
# misc
, lib
, src
# extra deps
}:
python3Packages.buildPythonPackage {
  pname = "Automatic1111";
  format = "pyproject";
  version = "v1.6.0";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    semver
    mediapipe
    numpy
    torchsde
    uvicorn
    pyperclip
    invisible-watermark
    fastapi
    fastapi-events
    fastapi-socketio
    timm
    scikit-image
    controlnet-aux
    compel
    python-dotenv
    uvloop
    watchfiles
    httptools
    websockets
    dnspython
    albumentations
    opencv4
    pudb
    imageio
    imageio-ffmpeg
    compel
    npyscreen
    pytorch-lightning
    protobuf
    omegaconf
    test-tube
    einops
    taming-transformers-rom1504
    torch-fidelity
    torchmetrics
    transformers
    kornia
    k-diffusion
    picklescan
    diffusers
    pypatchmatch
    realesrgan
    pillow
    send2trash
    flask
    flask-cors
    dependency-injector
    gfpgan
    eventlet
    clipseg
    getpass-asterisk
    safetensors
    datasets
    accelerate
    huggingface-hub
    easing-functions
    dynamicprompts
    torchvision
    test-tube
  ];
  nativeBuildInputs = with python3Packages; [ pythonRelaxDepsHook pip ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" "fastapi-socketio" ];
  pythonRelaxDeps = [ "dnspython" "flask" "requests" "numpy" "pytorch-lightning" "torchsde" "uvicorn" "invisible-watermark" "accelerate" "scikit-image" "safetensors" "huggingface-hub" "torchvision" "test-tube" "fastapi" ];
  makeWrapperArgs = [
    '' --run 'ls .'
    ''
    # See note about consumer GPUs:
    # https://docs.amd.com/bundle/ROCm-Deep-Learning-Guide-v5.4.3/page/Troubleshooting.html
    " --set-default HSA_OVERRIDE_GFX_VERSION 10.3.0"

    '' --run 'export INVOKEAI_ROOT="''${INVOKEAI_ROOT:-$HOME/.invokeai}"' ''
    '' --run '
      if [[ ! -d "$INVOKEAI_ROOT" && "''${0##*/}" != invokeai-configure ]]
      then
        echo "State directory does not exist, running invokeai-configure"
        if [[ "''${NIXIFIED_AI_NONINTERACTIVE:-0}" != 0 ]]; then
          ${placeholder "out"}/bin/invokeai-configure --yes --skip-sd-weights
        else
          ${placeholder "out"}/bin/invokeai-configure
        fi
      fi
      '
    ''
  ];
  patchPhase = ''
  #runHook prePatch
    echo here
  '';
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://github.com/AUTOMATIC1111/stable-diffusion-webui";
    mainProgram = "stable-diffusion-webui";
  };
}
