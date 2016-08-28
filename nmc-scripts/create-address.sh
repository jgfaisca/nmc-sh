
#!/bin/bash
#
# Create Namecoin address
#

namecoin-cli getnewaddress &&
namecoin-cli listreceivedbyaddress 0 true
