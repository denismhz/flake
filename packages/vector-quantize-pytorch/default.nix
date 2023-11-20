{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, torch
, einops
}:

buildPythonPackage rec {
  pname = "vector_quantize_pytorch";
  version = "1.11.7";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kMKeWhnTXbI+ROPJ0LHVh7TQjonhRzXUQm+U8TgghSM=";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    torch
    einops
  ];

  pythonImportsCheck = [ "vector_quantize_pytorch" ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}