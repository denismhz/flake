{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
}:

buildPythonPackage rec {
  pname = "discord-webhook";
  version = "1.2.1";
  format = "pyproject";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-COB3vzKYNwvyMsUvGqrph/J6WbTRLdDaaA85f5N73ZU=";
  };

  propagatedBuildInputs = [ poetry-core ];

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "https://github.com/lovvskillz/python-discord-webhook";
    maintainers = with maintainers; [ ];
  };
}