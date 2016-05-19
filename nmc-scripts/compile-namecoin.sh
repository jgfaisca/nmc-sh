#!/bin/bash
#
# install nmc from source
# https://wiki.namecoin.org/index.php?title=Build_Namecoin_From_Source
#
sudo apt-get install libtool git
git clone https://github.com/namecoin/namecoin-core.git
cd namecoin-core
./autogen.sh
./configure --without-gui
make
