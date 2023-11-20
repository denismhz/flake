{ python3Packages,
sd-src,
sgm-src,
# misc
   lib
 , src
# extra deps
}:
let
              submodel = pkg: python3Packages.${pkg} + "/lib/python3.10/site-packages";
              taming-transformers = submodel "taming-transformers-rom1504";
              k_diffusion = submodel "k_diffusion";
              codeformer = (submodel "codeformer") + "/codeformer";
              blip = (submodel "blip") + "/blip";
            in
python3Packages.buildPythonPackage {
  pname = "Automatic1111";
  format = "other";
  version = "v1.6.0";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
      discord-webhook
      numexpr
      deforum
      ultralytics
      k_diffusion
      inflection
      gdown
      altair
      aiofiles
      openclip
      semver
      numpy
      rich
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
        
        #replace dirs in paths_internal.py
        #mkdir -p /var/lib/.webui
        sed -i 's#os\.path\.join(script_path, "config_states")#os\.path\.join(data_path, "config_states")#' ./modules/paths_internal.py
        #delete lines trying to pull git repos and setting up tests in launch.py
        sed -i '28,43d' launch.py

        #firstly, we need to make launch.py runnable by adding python shebang
        cat <<-EOF > exec_launch.py.unwrapped
        $(echo "#!/usr/bin/python") 
        $(cat launch.py) 
        EOF
        chmod +x exec_launch.py.unwrapped

        #creating wrapper around launch.py with PYTHONPATH correctly set
        makeWrapper "$(pwd)/exec_launch.py.unwrapped" exec_launch.py \
          --set-default PYTHONPATH $PYTHONPATH

        mkdir $out/bin
        pushd $out/bin
        ln -s ../exec_launch.py launch.py
        buck='$' #escaping $ inside shell inside shell is tricky
        #next is an additional shell wrapper, which sets sensible default args for CLI
        #additional arguments will be passed further
        cat <<-EOF > flake-launch
        #!/usr/bin/env bash 
        pushd $out        #For some reason, fastapi only works when current workdir is set inside the repo
        trap "popd" EXIT

        "$out/bin/launch.py" --skip-install "$buck{@}"
        EOF
          # below lie remnants of my attempt to make webui use similar paths as InvokeAI for models download
          # additions of such options in upstream is a welcome sign, however they're mostly ignored and therefore useless
          # TODO: check in 6 months, maybe it'll work
          # For now, your best bet is to use ZFS dataset with dedup enabled or make symlinks after the fact
            
          #--codeformer-models-path "\$mp/codeformer" \
          #--gfpgan-models-path "\$mp/gfpgan" --esrgan-models-path "\$mp/esrgan" \
          #--bsrgan-models-path "\$mp/bsrgan" --realesrgan-models-path "\$mp/realesrgan" \
          #--clip-models-path "\$mp/clip" 
        chmod +x flake-launch
        popd

        runHook postBuild
      '';
              installPhase = ''
                runHook preInstall

                rm -rf repositories/
                mkdir repositories
                pushd repositories
                ln -s ${sd-src}/ stable-diffusion-stability-ai
                ln -s ${sgm-src}/ generative-models
                ln -s ${taming-transformers}/ taming-transformers
                ln -s ${k_diffusion}/ k-diffusion
                ln -s ${codeformer}/ CodeFormer
                ln -s ${blip}/ BLIP
                popd
                echo $PATH
                runHook postInstall
              '';
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://github.com/AUTOMATIC1111/stable-diffusion-webui";
    mainProgram = "flake-launch";
  };
}
