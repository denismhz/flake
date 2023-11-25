{ lib
, pythonRelaxDepsHook
, pip
, src
, deforum
, inflection
, gdown
, altair
, aiofiles
, openclip
, semver
, numpy
, torchsde
, uvicorn
, pyperclip
, invisible-watermark
, fastapi
, fastapi-events
, fastapi-socketio
, timm
, scikit-image
, controlnet-aux
, compel
, python-dotenv
, uvloop
, watchfiles
, httptools
, websockets
, dnspython
, albumentations
, opencv4
, pudb
, imageio
, imageio-ffmpeg
, npyscreen
, pytorch-lightning
, protobuf
, omegaconf
, test-tube
, einops
, taming-transformers-rom1504
, torch-fidelity
, torchmetrics
, transformers
, kornia
, k-diffusion
, picklescan
, diffusers
, pypatchmatch
, realesrgan
, pillow
, send2trash
, flask
, flask-cors
, dependency-injector
, gfpgan
, eventlet
, clipseg
, getpass-asterisk
, safetensors
, datasets
, accelerate
, easing-functions
, dynamicprompts
, torchvision
, lark
, gradio
, gradio-client
, tomesd
, piexif
, blendmodes
, poetry-core
, xformers
, python-multipart
, buildPythonPackage
, easygui
, rich
}:
buildPythonPackage {
  pname = "kohya_ss";
  format = "pyproject";
  version = "v22.1.1";
  inherit src;
  propagatedBuildInputs = [
    deforum
    rich
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
    poetry-core
    xformers
    python-multipart
    easygui
  ];
  nativeBuildInputs = [ pythonRelaxDepsHook pip ];
  pythonRemoveDeps = [ "clip" "pyreadline3" "flaskwebgui" "opencv-python" ];
  pythonRelaxDeps = [ "dnspython" "flask" "requests" "numpy" "pytorch-lightning" "torchsde" "uvicorn" "invisible-watermark" "accelerate" "scikit-image" "safetensors" "torchvision" "test-tube" "fastapi" ];
  doCheck = false;
  dontUsePytestCheck = true;
  buildPhase = ''
    runHook preBuild
    mkdir -p dist
    mkdir -p $out
    cp -r . $out
    cd $out

    mkdir -p $out/bin
    sed -i "2i echo $OSTYPE" $out/setup.sh
    chmod +x kohya_gui.py
    sed -i '10d' $out/library/localization.py
    sed -i "10i\ \ \ \ dirname = '$out/localizations'" $out/library/localization.py
    sed -i "1i #!/bin/python" $out/kohya_gui.py 
    echo "$(python --version)"
    makeWrapper $out/kohya_gui.py $out/bin/gui_wrapped.py --set-default PYTHONPATH $PYTHONPATH 
    chmod +x $out/bin/gui_wrapped.py

    runHook postBuild
  '';

  meta = {
    description = "GUI for Kohya's Stable Diffusion trainers";
    homepage = "https://github.com/bmaltais/kohya_ss.git";
    mainProgram = "gui_wrapped.py";
  };
}
