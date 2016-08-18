
#!/bin/bash
#
# Create Namecoin address
#

namecoind getnewaddress &&
namecoind listreceivedbyaddress 0 true
