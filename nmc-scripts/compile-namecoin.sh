#!/bin/bash
#
# install Namecoin from source
# https://github.com/namecoin/namecoin-core/blob/master/doc/build-unix.md
# 
# Namecoin node with wallet
#

# -- Install main depencencies --
apt-get update && apt-get install -y libboost-all-dev \
        dh-autoreconf curl libcurl4-openssl-dev \
        git apg libboost-all-dev build-essential libtool \
        libevent-dev wget bsdmainutils autoconf \
        apg libqrencode-dev libcurl4-openssl-dev \
        automake make libssl-dev libminiupnpc-dev \
        pkg-config libdb++-devv libzmq3-dev

# -- Install BerkeleyDB 4.8 (required for the wallet) --
add-apt-repository -y ppa:bitcoin/bitcoin && sudo apt-get update \
        && apt-get install libdb4.8-dev libdb4.8++-dev

[ -d "namecoin-core" ] || git clone https://github.com/namecoin/namecoin-core.git

# -- Compile Namecoin --
cd namecoin-core
./autogen.sh
# CXX flags tuned to conserve memory
CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768"
./configure \
        CXXFLAGS="$CXXFLAGS" \
        --enable-cxx \
        --disable-shared \
        --with-pic \
        --without-gui \
        --enable-upnp-default
        make && make install

cd / \
          && apt-get autoremove -y \
          && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
