
{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
}:

buildPythonPackage rec {
  pname = "rich";
  version = "13.7.0";
  format = "pyproject";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-XLUSO1z57nBYQkQkaBbpEUIn4LmK2Rdu7eatVL9UA/o=";
  };

  propagatedBuildInputs = [ poetry-core ];

  doCheck = false;

  meta = with lib; {
    description = "Rich is a Python library for rich text and beautiful formatting in the terminal.";
    homepage = "https://github.com/Textualize/rich";
    maintainers = with maintainers; [ ];
  };
}
