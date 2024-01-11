{ src 
, buildPythonPackage
, torchvision-bin
, torch-bin
, safetensors
, psutil
, einops
, transformers
, scipy
, torchsde
, pillow
, torch
, torchvision
, accelerate
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

  buildPhase =
  ''
    runHook preBuild
    
    mkdir -p dist
    cp -R . $out
    chmod -R +w $out
    cd $out

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

  #Tiled VAE supported without additional dependencies
  #Infinit image browser couple of deps
  #civit-ai browser + couple of deps
  #animatediff --> needs deforum for frame interpolation
  #deforum
  #controlnet
}
