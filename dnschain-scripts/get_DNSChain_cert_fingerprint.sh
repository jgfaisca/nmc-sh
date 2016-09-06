#!/bin/bash
# print dnschain certificate fingerprint

SHA256=$(openssl x509 -in .dnschain/cert.pem -noout -sha256 -fingerprint)

SHA1=$(openssl x509 -in .dnschain/cert.pem -noout -sha1 -fingerprint)

echo $SHA256
echo "${SHA256//:}"
echo "----------------"
echo $SHA1
echo "${SHA1//:}"


