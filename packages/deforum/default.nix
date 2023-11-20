{ lib
, buildPythonPackage
, fetchPypi
, pydantic
, starlette
, pytestCheckHook
, pytest-asyncio
, aiosqlite
, flask
, httpx
, hatchling
, orjson
, passlib
, peewee
, python-jose
, sqlalchemy
, trio
, pythonOlder
, setuptools
}:

buildPythonPackage rec {
  pname = "deforum";
  version = "0.1.7";

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-vLwkSVj9gD6oDOeybQ4tTwcwey4mWuXYCjw9qFoaFsA="; 
  };

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    starlette
    pydantic
  ];

  doCheck = false;


  meta = with lib; {
    description = "Deforum is a Python package for diffusion animation toolkit.";
    homepage = "https://github.com/deforum-art/deforum";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}


