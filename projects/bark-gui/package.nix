{ lib
, buildPythonPackage
, fetchFromGitHub
, writeShellScript
, setuptools

  # dependencies
, fairseq
, audiolm-pytorch
, gradio
, funcy
, linkify-it-py
, mutagen
, pytorch-seed
, pyyaml
, sentencepiece
, transformers

, ffmpeg-full

, src
}:

buildPythonPackage rec {
  pname = "bark-gui";
  format = "pyproject";
  version = "0.7.1";

  propagatedBuildInputs = [
    fairseq
    audiolm-pytorch
    gradio
    funcy
    linkify-it-py
    mutagen
    pytorch-seed
    pyyaml
    sentencepiece
    transformers
  ];
  buildInputs = [
    setuptools
    ffmpeg-full
  ];

  dontWrapPythonPrograms = true;
  postFixup =
    let
      setupScript = writeShellScript "bark-gui" ''
        if [[ ! -d $HOME/.bark-gui ]]; then
          mkdir -p $HOME
          cp -r ${src} $HOME/.bark-gui
          chmod 0755 $HOME/.bark-gui
          chmod 0644 $HOME/.bark-gui/config.yaml
          mkdir -p $HOME/.bark-gui/training/data/output
          mkdir -p $HOME/.bark-gui/training/inputtext
          chmod 755 $HOME/.bark-gui/training/data/output $HOME/.bark-gui/training/inputtext $HOME/.bark-gui/bark/assets/prompts/custom/
        fi
        pushd "$PWD"
        cd $HOME/.bark-gui/
        MYOLDPATH="$PATH"
        export PATH="$PATH:${ffmpeg-full.bin}/bin/"
        python webui.py "$@"
        export PATH="$MYOLDPATH"
        popd
      '';
    in
    ''
      mkdir -p $out/bin
      ln -s ${setupScript} $out/bin/bark-gui
    '';

  meta = {
    description = "A Gradio Web UI for an extended - easy to use - Bark Version";
    homepage = "https://github.com/C0untFloyd/bark-gui";
    mainProgram = "bark-gui";
  };
}
