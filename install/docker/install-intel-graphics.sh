if [ "$(uname -m)" != "x86_64" ]
then
    echo "Intel graphics will not be installed on this architecture."
    exit 0
fi

# no errors beyond this point
set -e

# the intel provided script is disabled since it does not work with the 6.8 kernel in Ubuntu 24.04 or Proxmox 8.2.
# manual installation of the Intel graphics stuff is required.

# echo "Installing Intel graphics packages."
# apt-get update && apt-get install -y gpg-agent &&
# rm -f /usr/share/keyrings/intel-graphics.gpg &&
# curl -L https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor --yes --output /usr/share/keyrings/intel-graphics.gpg &&
# echo 'deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy arc' | tee  /etc/apt/sources.list.d/intel.gpu.jammy.list &&
# apt-get -y update &&
# apt-get -y install intel-opencl-icd &&
# apt-get -y dist-upgrade;

# need intel-media-va-driver-non-free, but all the other intel packages are installed from Intel github.
echo "Installing Intel graphics packages."
apt-get update && apt-get install -y gpg-agent &&
rm -f /usr/share/keyrings/intel-graphics.gpg &&
curl -L https://repositories.intel.com/graphics/intel-graphics.key | gpg --dearmor --yes --output /usr/share/keyrings/intel-graphics.gpg &&
echo 'deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy arc' | tee  /etc/apt/sources.list.d/intel.gpu.jammy.list &&
apt-get -y update &&
apt-get -y install intel-media-va-driver-non-free &&
apt-get -y dist-upgrade;

# manual installation
# https://github.com/intel/compute-runtime/releases/tag/24.13.29138.7


rm -rf /tmp/gpu && mkdir -p /tmp/gpu && cd /tmp/gpu

apt-get install -y ocl-icd-libopencl1

curl -O -L https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17193.4/intel-igc-core_1.0.17193.4_amd64.deb
curl -O -L https://github.com/intel/intel-graphics-compiler/releases/download/igc-1.0.17193.4/intel-igc-opencl_1.0.17193.4_amd64.deb
curl -O -L https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-level-zero-gpu-dbgsym_1.3.30049.6_amd64.ddeb
curl -O -L https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-level-zero-gpu_1.3.30049.6_amd64.deb
curl -O -L https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-opencl-icd-dbgsym_24.26.30049.6_amd64.ddeb
curl -O -L https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/intel-opencl-icd_24.26.30049.6_amd64.deb
curl -O -L https://github.com/intel/compute-runtime/releases/download/24.26.30049.6/libigdgmm12_22.3.20_amd64.deb

dpkg -i *.deb

cd /tmp && rm -rf /tmp/gpu

apt-get -y dist-upgrade
