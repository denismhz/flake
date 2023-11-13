# WARNING: This file was automatically generated. You should avoid editing it.
# If you run pynixify again, the file will be either overwritten or
# deleted, and you will lose the changes you made to it.

{ buildPythonPackage
, fetchFromGitHub
, ftfy
, huggingface-hub
, lib
, regex
, sentencepiece
, torch
, torchvision
, tqdm
, protobuf
, fetchPypi
}:

buildPythonPackage rec {
  pname = "open-clip-torch";
  version = "2.7.0";
  format = "setuptools";
  

  src = fetchTarball {
    url = "https://files.pythonhosted.org/packages/eb/e5/1f5469f53ea8b09661984fedf41cd55b7585e2e0c7a2d245255ab0fb385e/open_clip_torch-2.7.0.tar.gz";
    sha256 = "sha256:16133ym9fzcv8a0h84213hsy083sf0ali5qqfsgyadm28x5w4avi";
  };

  propagatedBuildInputs = [
    torch
    torchvision
    regex
    ftfy
    tqdm
    huggingface-hub
    sentencepiece
    protobuf
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
  };
}
