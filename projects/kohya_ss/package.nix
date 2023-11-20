{ python3Packages
 , lib
 , src
}:
python3Packages.buildPythonPackage {
  pname = "kohya_ss";
  format = "other";
  version = "v22.1.1";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
      deforum
      inflection
      gdown
      altair
      aiofiles
      openclip
      semver
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
      easing-functions
      dynamicprompts
      torchvision
      test-tube
      lark
      gradio
      gradio-client
      tomesd
      piexif
      blendmodes
      xformers
      python-multipart
      ]; 
  nativeBuildInputs = with python3Packages; [ pythonRelaxDepsHook pip ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" ];
  pythonRelaxDeps = [ "dnspython" "flask" "requests" "numpy" "pytorch-lightning" "torchsde" "uvicorn" "invisible-watermark" "accelerate" "scikit-image" "safetensors" "torchvision" "test-tube" "fastapi" ];

  dontUsePytestCheck = true;

  doCheck = false;

  buildPhase = ''
                runHook preBuild
                mkdir -p dist
                cp -r . $out
                chmod -R +w $out
                cd $out

                --run setup.sh
                mkdir -p $out/bin
                mv gui.sh $out/bin/gui.sh

                runHook postBuild
              '';
              installPhase = ''
                runHook preInstall

                runHook postInstall
              '';
  meta = {
    description = "GUI for Kohya's Stable Diffusion trainers";
    homepage = "https://github.com/bmaltais/kohya_ss.git";
    mainProgram = "gui.sh";
  };
}
