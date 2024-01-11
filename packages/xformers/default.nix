{ lib
, buildPythonPackage
, pythonOlder
, fetchFromGitHub
, which
# runtime dependencies
, numpy
, torch
# check dependencies
, pytestCheckHook
, pytest-cov
# , pytest-mpi
, pytest-timeout
# , pytorch-image-models
, hydra-core
, fairscale
, scipy
, cmake
, openai-triton
, networkx
#, apex
, einops
, transformers
, timm
#, flash-attn
, cudaPackages
, stable-pkgs
}:
let
  inherit (cudaPackages) cudaFlags cudnn;

  # Some packages are not available on all platforms
  nccl = cudaPackages.nccl or null;

  setBool = v: if v then "1" else "0";

  # https://github.com/pytorch/pytorch/blob/v2.0.1/torch/utils/cpp_extension.py#L1744
  supportedTorchCudaCapabilities =
    let
      real = ["3.5" "3.7" "5.0" "5.2" "5.3" "6.0" "6.1" "6.2" "7.0" "7.2" "7.5" "8.0" "8.6" "8.7" "8.9" "9.0"];
      ptx = lists.map (x: "${x}+PTX") real;
    in
    real ++ ptx;

  # NOTE: The lists.subtractLists function is perhaps a bit unintuitive. It subtracts the elements
  #   of the first list *from* the second list. That means:
  #   lists.subtractLists a b = b - a

  # For CUDA
  supportedCudaCapabilities = lists.intersectLists cudaFlags.cudaCapabilities supportedTorchCudaCapabilities;
  unsupportedCudaCapabilities = lists.subtractLists supportedCudaCapabilities cudaFlags.cudaCapabilities;

  # Use trivial.warnIf to print a warning if any unsupported GPU targets are specified.
  gpuArchWarner = supported: unsupported:
    trivial.throwIf (supported == [ ])
      (
        "No supported GPU targets specified. Requested GPU targets: "
        + strings.concatStringsSep ", " unsupported
      )
      supported;

  # Create the gpuTargetString.
  gpuTargetString = strings.concatStringsSep ";" (
    if gpuTargets != [ ] then
    # If gpuTargets is specified, it always takes priority.
      gpuTargets
    else if rocmSupport then
      rocmPackages.clr.gpuTargets
    else
      gpuArchWarner supportedCudaCapabilities unsupportedCudaCapabilities
  );

  version = "0.0.22.post7";
in
buildPythonPackage {
  pname = "xformers";
  inherit version;
  format = "setuptools";

  disabled = pythonOlder "3.7";

  src = fetchFromGitHub {
    owner = "facebookresearch";
    repo = "xformers";
    rev = "refs/tags/v${version}";
    hash = "sha256-7lZi3+2dVDZJFYCUlxsyDU8t9qdnl+b2ERRXKA6Zp7U=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    export TORCH_CUDA_ARCH_LIST="${gpuTargetString}"
    export CUDNN_INCLUDE_DIR=${cudnn.dev}/include
    export CUDNN_LIB_DIR=${cudnn.lib}/lib
    export CUPTI_INCLUDE_DIR=${cudaPackages.cuda_cupti.dev}/include
    export CUPTI_LIBRARY_DIR=${cudaPackages.cuda_cupti.lib}/lib
    export CUDA_PATH=${stable-packages.cudatoolkit}
    export EXTRA_LD_FLAGS="-L${stable-pkgs.linuxPackages.nvidia_x11_production}/lib"
  '';

  preBuild = ''
    cat << EOF > ./xformers/version.py
    # noqa: C801
    __version__ = "${version}"
    EOF
  '';

  nativeBuildInputs = [
    which
  ] ++ (with cudaPackages; [
    autoAddOpenGLRunpathHook
    cuda_nvcc
  ]);

  propagatedBuildInputs = [
    numpy
    torch
  ];

  buildInputs = with cudaPackages; [
      cuda_cccl.dev # <thrust/*>
      cuda_cudart # cuda_runtime.h and libraries
      cuda_cupti.dev # For kineto
      cuda_cupti.lib # For kineto
      cuda_nvcc.dev # crt/host_config.h; even though we include this in nativeBuildinputs, it's needed here too
      cuda_nvml_dev.dev # <nvml.h>
      cuda_nvrtc.dev
      cuda_nvrtc.lib
      cuda_nvtx.dev
      cuda_nvtx.lib # -llibNVToolsExt
      cudnn.dev
      cudnn.lib
      libcublas.dev
      libcublas.lib
      libcufft.dev
      libcufft.lib
      libcurand.dev
      libcurand.lib
      libcusolver.dev
      libcusolver.lib
      libcusparse.dev
      libcusparse.lib
      effectiveMagma
      numactl
    ] ++ [stable-pkgs.linuxPackages.nvidia_x11_production gcc stable-packages.cudatoolkit];

  pythonImportsCheck = [ "xformers" ];

  dontUseCmakeConfigure = true;

  # see commented out missing packages
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov
    pytest-timeout
    hydra-core
    fairscale
    scipy
    cmake
    networkx
    openai-triton
    # apex
    einops
    transformers
    timm
    # flash-attn
  ];

  meta = with lib; {
    description = "XFormers: A collection of composable Transformer building blocks";
    homepage = "https://github.com/facebookresearch/xformers";
    changelog = "https://github.com/facebookresearch/xformers/blob/${version}/CHANGELOG.md";
    license = licenses.bsd3;
    maintainers = with maintainers; [ happysalada ];
  };
}