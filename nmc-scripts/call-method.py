# Generic JSON-RPC call (python)

headers = {
    'content-type': 'text/plain;',
}

data = '{"jsonrpc":"1.0","id":"curltext","method":"${method}","params":["${params}"]}'

requests.post('http://${HOST}:${RPC_PORT}', headers=headers, data=data)
