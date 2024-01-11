{ python3Packages
, # misc
  lib
, src
  # extra deps
}:
python3Packages.buildPythonPackage {
  pname = "bark-gui";
  format = "setuptools";
  version = "07.1";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    audiolm-pytorch
    boto3
    ema-pytorch
    encodec
    funcy
    gradio
    local-attention
    pytorch-seed
    safetensors
    scipy
    torch
    torchaudio
    transformers
    vector-quantize-pytorch
  ];
  #nativeBuildInputs = with python3Packages; [ pythonRelaxDepsHook pip ];
  nativeBuildInputs = with python3Packages; [ setuptools pip ];

  makeWrapperArgs = [
    '' --set-default PYTHONPATH=$PYTHONPATH ''
  ];

  buildPhase = ''
    mkdir -p dist
    runHook preBuild
    cp -r . $out
    chmod -R +w $out
    cd $out

    chmod +x webui.py
    #add shbang to webui.py
    cat <<-EOF > webui.py
    $(echo "#!/usr/bin/python") 
    $(cat webui.py) 
    EOF

    mkdir -p $out/bin
    ln -s webui-wrapped.py $out/bin/bark-gui 
    makeWrapper "$(pwd)/webui.py" "$out/bin/bark-gui" --set-default PYTHONPATH=$PYTHONPATH
    chmod +x $out/bin/bark-gui
        
    runHook postBuild
  '';

  meta = {
    description = "A Gradio Web UI for an extended - easy to use - Bark Version.";
    homepage = "https://github.com/C0untFloyd/bark-gui";
    mainProgram = "bark-gui";
  };
}

