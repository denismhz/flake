{ python3Packages
, sd-src
, sgm-src
, # misc
  lib
, src
  # extra deps
}:
python3Packages.buildPythonPackage {
  pname = "Automatic1111";
  format = "other";
  version = "v1.6.0";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    aiofiles
    analytics-python
    altair
    blendmodes
    codeformer
    einops
    facexlib
    gfpgan
    gradio
    gradio-client
    inflection
    k-diffusion
    kornia
    lark
    openclip
    omegaconf
    piexif
    pytorch-lightning
    realesrgan
    safetensors
    semantic-version
    taming-transformers-rom1504
    timm
    tomesd
    torch
    transformers
    xformers

    #For Extensions -- dont know if e.g you dont install image browser then maybe lack of dep for civitai browser
    pyfunctional #infinite image browser
    dill #infinite image browser
    python-dotenv #infinite image browser
    fastapi #infinite image browser
    uvicorn #infinite image browser
    tabulate #infinite image browser
    #infinite image browser sends dleted images to nirvana

    send2trash #civitai browser+
    zipunicode #civitai browser+
    fake-useragent #civitai browser+

    rich #adetailer
    ultralytics #adetailer
    py-cpuinfo #adetailer
    mediapipe #adeteailer
    
    av #animatediff to create webm and other fileformats

    numexpr #deforum
    deforum #deforum
  ];

  patches = [ ./_outputpaths.patch ];

  buildPhase =
  ''
    runHook preBuild
    
    mkdir -p dist
    cp -r . $out
    chmod -R +w $out
    cd $out

    sed -i '28,43d' launch.py

    substituteInPlace ./modules/paths_internal.py \
      --replace 'os.path.join(script_path, "config_states")' \
                'os.path.join(data_path, "config_states")'
    
    substituteInPlace ./modules/shared_gradio_themes.py \
      --replace script_path data_path

    #make launch.py executable > shebang
    mkdir -p $out/bin
    cat <<-EOF > launch.py
    $(echo "#!/usr/bin/python") 
    $(cat launch.py) 
    EOF
    chmod +x launch.py
    makeWrapper "$out/launch.py" $out/bin/launch-wrapped.py \
      --run 'export COMMANDLINE_ARGS="''${COMMANDLINE_ARGS:-\
      --data-dir $HOME/webui --skip-install \
      --theme dark --ckpt-dir $HOME/webui/models/ckpt \
      --embeddings-dir $HOME/webui/models/embeddings \
      --medvram --no-half-vae}"' \
      --set-default PYTHONPATH $PYTHONPATH \
      --chdir $out

    rm -rf dist

    runHook postBuild
  '';

  installPhase =
    let
      submodel = pkg: python3Packages.${pkg} + "/lib/python3.10/site-packages";
      taming-transformers = submodel "taming-transformers-rom1504";
      k_diffusion = submodel "k_diffusion";
      codeformer = (submodel "codeformer") + "/codeformer";
      blip = (submodel "blip") + "/blip";
    in
    ''
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

      runHook postInstall
    '';
  meta = {
    description = "Fancy Web UI for Stable Diffusion";
    homepage = "https://github.com/AUTOMATIC1111/stable-diffusion-webui";
    mainProgram = "launch-wrapped.py";
  };

  #Tiled VAE supported without additional dependencies
  #Infinit image browser couple of deps
  #civit-ai browser + couple of deps
  #animatediff --> needs deforum for frame interpolation
  #deforum
  #controlnet
}
