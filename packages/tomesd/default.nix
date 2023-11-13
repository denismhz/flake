{ buildPythonPackage, fetchPypi, lib, torch, numpy, pyre-extensions, pythonRelaxDepsHook, which }:

buildPythonPackage rec {
  pname = "tomesd";
  version = "0.1.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Fbui6VL0ZDyDVZUeiS/akY3cy9/yI43DaNQr0Hj87ck=";
  };
  nativeBuildInputs = [ pythonRelaxDepsHook which ];

  # TODO FIXME
  doCheck = false;

  meta = with lib; { };
}
