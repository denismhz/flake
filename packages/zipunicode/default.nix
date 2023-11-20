{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "ZipUnicode";
  version = "1.1.1";
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