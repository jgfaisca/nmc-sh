#!/bin/bash
####################################################################
#
# Generic JSON-RPC call
#
# usage:
# ./call-method.sh <method> <params>
#
# example:
# ./call-method.sh dumpprivkey NEv8dd3sxN7gV7RnWy9VefPqWswxhbc28c
#
# authors:
# jose G. Faisca <jose.faisca@gmail.com>
#
####################################################################


if [ $# -ne 2 ]; then
  echo
  echo "Invalid number of arguments."
  echo "Usage: ./$(basename "$0") <method> <params>"
  echo
  exit 1
fi

DATADIR=/data/namecoin
CONF=namecoin.conf
HOST="127.0.0.1"

RPC_USER=$(cat $DATADIR/$CONF | grep rpcuser | awk -F '[/=]' '{print $2}')
RPC_PASS=$(cat $DATADIR/$CONF | grep rpcpassword | awk -F '[/=]' '{print $2}')
RPC_PORT=$(cat $DATADIR/$CONF | grep rpcport | awk -F '[/=]' '{print $2}')

function call(){
  method="$1"
  params="$2"
  return=$(curl -D -sS --user ${RPC_USER}:${RPC_PASS} \
        --data-binary '{"jsonrpc":"1.0","id":"curltext","method":"'"${method}"'","params":["'"${params}"'"]}' \
        -H 'content-type: text/plain;' \
        http://${HOST}:${RPC_PORT})
  echo $return
}

function print_json(){
  json_pp -v >/dev/null 2>&1
  if [ $? -ne 0 ]; then
     echo "$1"
  else
     echo "$1" | json_pp
  fi
}

print_json $(call "$1" "$2")

