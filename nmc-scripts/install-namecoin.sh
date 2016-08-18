#!/bin/bash

OSVERSION="xUbuntu_16.04"

DIR=$HOME
[ -d "$DIR/.namecoin" ] && rm -rfi "$DIR/.namecoin"

# Install Namecoin from repository.
apt-get update && \
    apt-get install -y curl  && \	
    curl -sL http://download.opensuse.org/repositories/home:p_conrad:coins/${OSVERSION}/Release.key | apt-key add -  && \
    echo "deb http://download.opensuse.org/repositories/home:/p_conrad:/coins/${OSVERSION}/ /" > /etc/apt/sources.list.d/namecoin.list && \
    apt-get update && \
    apt-get install -y namecoin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/apt/*

# Configure Namecoin
mkdir -p $DIR/.namecoin &&
echo "rpcuser=`whoami`" >> $DIR/.namecoin/namecoin.conf &&
echo "rpcpassword=`openssl rand -hex 30/`" >> $DIR/.namecoin/namecoin.conf &&
echo "rpcport=8336" >> $DIR/.namecoin/namecoin.conf &&
echo "daemon=1" >> $DIR/.namecoin/namecoin.conf &&

