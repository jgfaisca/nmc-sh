#!/bin/bash
#########################################################
#
# Lookup Namecoin name using RPC connection on localhost
#
# usage:
# ./lookup-name.sh <name>
#
# example:
# ./lookup-name.sh d/okturtles
#
# authors:
# jose G. Faisca <jose.faisca@gmail.com>
#
#########################################################

if [ $# -ne 1 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <namecoin_name>"
  echo
  exit 1
fi

DATADIR=/data/namecoin
CONF=namecoin.conf
HOST="127.0.0.1"
NAME="$1"

RPC_USER=$(cat $DATADIR/$CONF | grep rpcuser | awk -F '[/=]' '{print $2}')
RPC_PASS=$(cat $DATADIR/$CONF | grep rpcpassword | awk -F '[/=]' '{print $2}')
RPC_PORT=$(cat $DATADIR/$CONF | grep rpcport | awk -F '[/=]' '{print $2}')

# lookup name
JSON=$(curl -D -sS --user ${RPC_USER}:${RPC_PASS} \
        --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"name_show","params":["'"${NAME}"'"]}' \
        -H 'content-type: text/plain;' \
        http://${HOST}:${RPC_PORT})

echo $JSON | json_pp
