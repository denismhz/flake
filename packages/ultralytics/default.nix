{ lib
, buildPythonPackage
, fetchPypi
, poetry-core
}:

buildPythonPackage rec {
  pname = "ultralytics";
  version = "8.0.211";
  
  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-QZio7nuNFRYBwa+wUWM7uQ056M3GsRHGcqnrysfvN6E=";
  };

  propagatedBuildInputs = [ poetry-core ];

  doCheck = false;

  meta = with lib; {
    description = "";
    homepage = "https://github.com/ultralytics/ultralytics";
    maintainers = with maintainers; [ ];
  };
}
