
var request = require('request');

var headers = {
    'content-type': 'text/plain;'
};

var dataString = '{"jsonrpc":"1.0","id":"curltext","method":"${method}","params":["${params}"]}';

var options = {
    url: 'http://${HOST}:${RPC_PORT}',
    method: 'POST',
    headers: headers,
    body: dataString
};

function callback(error, response, body) {
    if (!error && response.statusCode == 200) {
        console.log(body);
    }
}

request(options, callback);
