{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "discord-webhook";
  version = "1.3.0";
  format = "pyproject";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "";
  };

  propagatedBuildInputs = [ ];

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "https://github.com/lovvskillz/python-discord-webhook";
    maintainers = with maintainers; [ ];
  };
}