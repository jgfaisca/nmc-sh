#!/bin/bash
# generate DNSChain key + certificate

subject="/C=PT/ST=Europe/L=Lisbon/O=NEMPS/OU=WORKSHOP/CN=*.chainlab.tk"
key_file=".dnschain/key.pem"
cert_file=".dnschain/cert.pem"

openssl req -new -newkey rsa:4096 -days 3650 -nodes -sha256 -x509 \
            -subj $subject \
            -keyout $key_file \
            -out $cert_file

openssl x509 -in $cert_file -text
