{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, torch
, einops
}:

buildPythonPackage rec {
  pname = "local-attention";
  version = "1.9.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p7F53JIjWLS7SLMXLPs0nttFnRvc5YnYN4alel42kKY=";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    torch
    einops
  ];

  pythonImportsCheck = [ "local_attention" ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}