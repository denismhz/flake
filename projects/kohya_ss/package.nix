{ lib
, python3Packages
, src
}:
python3Packages.buildPythonPackage {
  pname = "kohya_ss";
  format = "pyproject";
  version = "v22.1.1";
  inherit src;
  propagatedBuildInputs = with python3Packages; [
    altair
    easygui
    gradio
    gradio-client
    psutil
    rich
    semantic-version
  ];
  
  buildPhase = ''
    runHook preBuild
    mkdir -p dist
    mkdir -p $out
    cp -r . $out
    cd $out

    mkdir -p $out/bin
    sed -i "2i echo $OSTYPE" $out/setup.sh
    chmod +x kohya_gui.py
    sed -i "1i #!/bin/python" $out/kohya_gui.py 
    
    #why do i have to replace all the paths :(
    substituteInPlace ./finetune_gui.py ./library/localization.py ./lora_gui.py ./kohya_gui.py \
      --replace './' "$out/"
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
