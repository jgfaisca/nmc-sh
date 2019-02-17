#!/usr/bin/python
# dependencies:
# pip install python-bitcoinrpc
#

rpc_user = "rpc"
rpc_password = "secret"
rpc_host = "10.17.0.2"
rpc_port = "8336"

from bitcoinrpc.authproxy import AuthServiceProxy, JSONRPCException
import logging

logging.basicConfig()
logging.getLogger("RPC").setLevel(logging.DEBUG)

# rpc_user and rpc_password are set in the bitcoin.conf file
rpc_connection = AuthServiceProxy(
    "http://%s:%s@%s:%s"%(rpc_user, rpc_password, rpc_host, rpc_port),
    timeout=120)

#best_block_hash = rpc_connection.getbestblockhash()
#print(rpc_connection.getblock(best_block_hash))
# batch support : print timestamps of blocks 0 to 99 in 2 RPC round-trips:
#commands = [ [ "getblockhash", height] for height in range(100) ]
#block_hashes = rpc_connection.batch_(commands)
#blocks = rpc_connection.batch_([ [ "getblock", h ] for h in block_hashes ])
#block_times = [ block["time"] for block in blocks ]
#print(block_times)

json_data = rpc_connection.getblockchaininfo()
print(json_data)

