{ lib
, buildPythonPackage
, fetchPypi
, setuptools
, chardet
}:

buildPythonPackage rec {
  pname = "ZipUnicode";
  version = "1.1.1";
  format = "pyproject";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2MbEWa7LnDENKhgzid664RULiAUSkW+5kBIDaOXTN/M=";
  };

  propagatedBuildInputs = [ setuptools chardet ];

  doCheck = false;

  meta = with lib; {
    description = "Make extracted unreadable filename problem gone away.";
    homepage = "https://github.com/Dragon2fly/ZipUnicode";
    maintainers = with maintainers; [ ];
  };
}