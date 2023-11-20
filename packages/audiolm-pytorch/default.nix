{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, packaging
, torch
, einops
, beartype
, torchaudio
, fairseq
, transformers
, vector-quantize-pytorch
, local-attention
, encodec
, lion-pytorch
, ema-pytorch
, accelerate
}:

buildPythonPackage rec {
  pname = "audiolm-pytorch";
  version = "1.7.6";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Roo17hhrlNqnAt43kKQRnkHn6fvtW+vEVxLVHK0k884=";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    packaging
    torch
    einops
    beartype
    torchaudio
    fairseq
    transformers
    vector-quantize-pytorch
    local-attention
    encodec
    lion-pytorch
    ema-pytorch
    accelerate
  ];

  pythonImportsCheck = [ "audiolm_pytorch" ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
