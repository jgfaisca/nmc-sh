#
#!/bin/bash
#
# Build and install Namecoin node from source (with wallet)
# https://github.com/namecoin/namecoin-core/blob/master/doc/build-unix.md
#
# Usage: ./build-namecoin-core.sh <cpu_cores>
#
# For instance, if you have 4 CPU cores, you can let make run 4 threads at once.
# $ ./build-namecoin-core.sh 4
#

# Default CPU cores = 1
CPU_CORES=${1:-1}

# -- Install main depencencies --
sudo apt-get update && sudo apt-get install -y \
        curl iproute2 git net-tools libboost-all-dev \
        dh-autoreconf curl libcurl4-openssl-dev \
        git apg libboost-all-dev build-essential libtool \
        libevent-dev wget bsdmainutils autoconf \
        apg libqrencode-dev libcurl4-openssl-dev \
        automake make libssl-dev libminiupnpc-dev \
        pkg-config libzmq3-dev autotools-dev

# -- Install BerkeleyDB 4.8 (required for the wallet) --
sudo apt-get install -y software-properties-common \
        && sudo add-apt-repository -y ppa:bitcoin/bitcoin \
        && sudo apt-get update \
        && sudo apt-get install -y libdb4.8-dev libdb4.8++-dev

# -- Clone Namecoin source repository --
git clone https://github.com/namecoin/namecoin-core.git

# -- Build and install Namecoin --
cd namecoin-core
./autogen.sh
# CXX flags tuned to conserve memory
./configure \
        CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768" \
        --enable-cxx \
        --disable-shared \
        --with-pic \
        --without-gui \
        --enable-upnp-default
make -j $CPU_CORES && sudo make install

# -- Clean --
cd .. 
rm -rf namecoin-core       
sudo apt-get autoremove -y
sudo apt-get clean 

exit 0
