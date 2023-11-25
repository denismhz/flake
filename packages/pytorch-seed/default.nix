{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, numpy
, torch
}:

buildPythonPackage rec {
  pname = "pytorch_seed";
  version = "0.2.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-CW7dNAT4oA898rq0ECSUWAa68fZLBWeMgjc7eARY4aM=";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    torch
    numpy
  ];

  pythonImportsCheck = [ "pytorch_seed" ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}