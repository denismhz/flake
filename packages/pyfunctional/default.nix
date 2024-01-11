
{ buildPythonPackage, lib, fetchPypi
}:

buildPythonPackage rec {
  pname = "PyFunctional";
  version = "1.4.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-EcMT/iUbJpxlBmiRNUVqBbxab6EpydArRF84PU9BHhA=";
  };

  propagatedBuildInputs = [
  ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; {
    description = "PyFunctional makes creating data pipelines easy by using chained functional operators.";
    homepage = "https://github.com/EntilZha/PyFunctional";
  };
}
