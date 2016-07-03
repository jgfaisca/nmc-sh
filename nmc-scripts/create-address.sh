
#!/bin/bash
#
# Create namecoin address
#

namecoind getnewaddress &&
namecoind listreceivedbyaddress 0 true
