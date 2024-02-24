{
  src,
  buildPythonPackage,
  safetensors,
  psutil,
  einops,
  transformers,
  scipy,
  torchsde,
  pillow,
  torch,
  torchvision,
  accelerate,
}:
buildPythonPackage {
  pname = "ComfyUI";
  format = "other";
  version = "latest";
  inherit src;
  propagatedBuildInputs = [
    accelerate
    torchvision
    torch
    safetensors
    psutil
    einops
    transformers
    scipy
    pillow
    torchsde
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p dist
    cp -R . $out
    chmod -R +w $out
    cd $out
    substituteInPlace ./folder_paths.py --replace 'os.path.join(base_path, "models")' '"/home/denis/comfyui/models"'
    substituteInPlace ./folder_paths.py --replace 'os.path.join(os.path.dirname(os.path.realpath(__file__)), "temp")' '"/home/denis/comfyui/temp"'
    substituteInPlace ./folder_paths.py --replace 'os.path.join(os.path.dirname(os.path.realpath(__file__)), "output")' '"/home/denis/comfyui/output"'
    substituteInPlace ./folder_paths.py --replace 'os.path.join(os.path.dirname(os.path.realpath(__file__)), "input")' '"/home/denis/comfyui/input"'
    #make main.py executable > shebang
    mkdir -p $out/bin
    cat <<-EOF > main.py
    $(echo "#!/usr/bin/python")
    $(cat main.py)
    EOF
    chmod +x main.py
    makeWrapper "$out/main.py" $out/bin/main-wrapped.py \
      --set-default PYTHONPATH $PYTHONPATH \

    rm -rf dist

    runHook postBuild
  '';

  meta = {
    description = "The most powerful and modular stable diffusion GUI and backend.";
    homepage = "https://github.com/comfyanonymous/ComfyUI.git";
    mainProgram = "main-wrapped.py";
  };
}
