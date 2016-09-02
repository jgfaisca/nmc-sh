
#!/bin/bash
#
# Create Namecoin address
#

namecoin-cli getnewaddress "account1" &&
namecoin-cli listreceivedbyaddress 0 true
