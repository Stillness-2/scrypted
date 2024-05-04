if [ "$(uname -m)" = "x86_64" ]
then
    # uncomment to require cuda 12, but everything currently targets 11.
    # stuff that targets 11 will work with 12 though. 
    # export CUDA_VERSION=12-4
    export CUDA_VERSION=11-8
    echo "Installing NVIDIA graphics packages."
    apt update -q \
        && apt install wget \
        && wget -qO /cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb \
        && dpkg -i /cuda-keyring.deb \
        && apt update -q \
        && apt install -y cuda-nvcc-$CUDA_VERSION libcublas-$CUDA_VERSION libcudnn8 cuda-libraries-$CUDA_VERSION;
    exit $?
else
    echo "NVIDIA graphics will not be installed on this architecture."
fi

exit 0