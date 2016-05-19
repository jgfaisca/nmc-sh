#!/bin/bash

DIR=$HOME
[ -d "$DIR/.namecoin" ] && rm -rfi "$DIR/.namecoin"
sudo apt-get update
sudo apt-get install namecoin &&
mkdir -p $DIR/.namecoin &&
echo "rpcuser=`whoami`" >> $DIR/.namecoin/namecoin.conf &&
echo "rpcpassword=`openssl rand -hex 30/`" >> $DIR/.namecoin/namecoin.conf &&
echo "rpcport=8336" >> $DIR/.namecoin/namecoin.conf &&
echo "daemon=1" >> $DIR/.namecoin/namecoin.conf &&
sudo service namecoind start &&
sudo service namecoind status
