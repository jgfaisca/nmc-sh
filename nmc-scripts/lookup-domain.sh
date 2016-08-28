#!/bin/bash
#########################################################
# 
# Lookup Namecoin domain using RPC connection on localhost
# 
# usage: 
# ./lookup-domain.sh <domain_name>
#
# example:
# ./lookup-domain.sh okturtles
#
# authors:
# jose G. Faisca <jose.faisca@gmail.com>
#
#########################################################

if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <domain_name>"
  echo
  exit 1
fi

DATADIR=$HOME/.namecoin
CONF=namecoin.conf
HOST="127.0.0.1"
NAME="d/$1"

RPC_USER=$(cat $DATADIR/$CONF | grep rpcuser | awk -F '[/=]' '{print $2}')
RPC_PASS=$(cat $DATADIR/$CONF | grep rpcpassword | awk -F '[/=]' '{print $2}')
RPC_PORT=$(cat $DATADIR/$CONF | grep rpcport | awk -F '[/=]' '{print $2}')

echo
echo "lookup domain $NAME ..."
echo 

# lookup domain name
curl -v -D - \
        --user $RPC_USER:$RPC_PASS \
        --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"getinfo","params":["${NAME"}]}' \
        -H 'content-type: text/plain;' \
        http://$HOST:$RPC_PORT
