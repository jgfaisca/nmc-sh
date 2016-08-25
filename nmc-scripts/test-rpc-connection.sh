#!/bin/bash
#########################################################
# 
# Test Namecoin RPC connection on localhost
# 
# usage: 
# ./test-rpc-connection <data_directory>
#
# example:
# ./test-rpc-connection /home/myuser/.namecoin
#
# authors:
# jose G. Faisca <jose.faisca@gmail.com>
#
#########################################################

if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <data_directory>"
  echo
  exit 1
fi

DATADIR=$1
CONF=namecoin.conf
HOST="127.0.0.1"

RPC_USER=$(cat $DATADIR/$CONF | grep rpcuser | awk -F '[/=]' '{print $2}')
RPC_PASS=$(cat $DATADIR/$CONF | grep rpcpassword | awk -F '[/=]' '{print $2}')
RPC_PORT=$(cat $DATADIR/$CONF | grep rpcport | awk -F '[/=]' '{print $2}')

curl \
        --user $RPC_USER:$RPC_PASS \
        --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"getinfo","params":[]}' \
        -H 'content-type: text/plain;' \
        http://$HOST:$RPC_PORT
