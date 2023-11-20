{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, torch
, beartype
}:

buildPythonPackage rec {
  pname = "ema-pytorch";
  version = "0.3.0";
  format = "pyproject";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-xZv/45dxN2aYUUAq9JRlCWcJnalAD1SuMbyU+//jBhw=";
  };

  buildInputs = [
    setuptools
  ];
  propagatedBuildInputs = [
    torch
    beartype
  ];

  pythonImportsCheck = [ "ema_pytorch" ];

  meta = with lib; {
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}