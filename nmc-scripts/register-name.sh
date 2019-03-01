#!/bin/bash 
###############################################################################
#
# Script to register Namecoin names (namespace/name)
#
# How to use:
# 1 - Install and configure the namecoin software
# https://wiki.namecoin.org/index.php?title=Install_and_Configure_Namecoin
# 2 - Print your Namecoin wallet address using the command:
# namecoin-cli listreceivedbyaddress 0 true
# 3 - Transfer namecoins (NMC) to your wallet using an exchage
# https://namecoin.org/?p=exchanges 
# 4 - Create <name.json> (a JSON-encoded file) with name information 
# For domain name JSON check http://dot-bit.org/tools/domainCheck.php
# 5 - Run this script 
# ./register-name.sh '<namespace/name>'
# <namespace/name> is your Namecoin name
# 
# Example: to register example.bit domain, first create the example.json
# file with name information and run:
# ./register-name.sh 'd/example'
#
# The key d/example signifies a record stored in the DNS namespace d
# with the name example and corresponds to the record for the example.bit
# website. The content of d/example is expected  to conform to the
# DNS namespace specification
#
# 6 - Wait at least 12 blocks, then update your name by running
# the script again:
# ./register-name.sh '<namespace/name>'
# 7 - To update the registered name, modify <name>.json and run:
# ./register-name.sh '<namespace/name>' --update
#
# authors:
# Jose G. Faisca <jose.faisca@gmail.com>
#
###############################################################################

NAME="$1" 			# name argument
NMC_NAME=""			# Namecoin name
NMC_SPEC=""			# Namecoin namespace
UPDATE="$2"			# update name argument
SHORTEX="" 			# short hex number
LONGHEX="" 			# longer hex code
CONF=0 				# blocks / confirmations
CONFMIN=12 			# minimum blocks before first update
JSONFILE="" 			# JSON file with name information
NEWFILE="" 			# output of name_new command
FIRSTUFILE="" 			# output of name_firstupdate command
UPDATEFILE=""			# output of name_update command
#DATADIR="$HOME/.namecoin"	# Namecoin data directory
DATADIR="/data/namecoin"

get_specName(){
  str="$1"
  cpos=0
  size=${#str}
  tmp="${str%%/*}"
  if [ "$tmp" != "$str" ]; then
     cpos=${#tmp}
     NMC_SPEC=${str:0:$cpos+1}
     NMC_NAME=${str:$cpos+1:$size}
     check_size "$NMC_NAME"
     JSONFILE="$NMC_NAME.json"
     NEWFILE="$NMC_NAME.new"
     FIRSTUFILE="$NMC_NAME.firstupdate"
     UPDATEFILE="$NMC_NAME.update"
     return 0
  else
     return 1
  fi
}

check_size(){
  str="$1"
  size=${#str}
  if [ "$NMC_SPEC" == "d/" ]; then
     if [ "$size" -gt 63 ]; then
	echo "The name $NAME must be 63 characters or less."
        return 1
     fi
  else
     if [ "$size" -gt 255 ]; then
	echo "The name $NAME must be 255 characters or less."
    	return 1
     fi
  fi
  return 0
}

check_domain(){
  domain="$1"
  domain="@${domain}.bit"
  dots=$(grep -o "[.]" <<<"$domain" | wc -l)
  {
    echo $domain |  grep -E "^@[a-zA-Z0-9]+([-.]?[a-zA-Z0-9]+)*.[a-zA-Z]+$" 
  } &> /dev/null
  if [ $? -eq 0 ] && [ $dots -eq 1 ]; then
     return 0
  else
     return 1
  fi
}

check_json(){
  {
    cat "$JSONFILE" | python -mjson.tool
  } &> /dev/null
  if [ $? -eq 0 ]; then
     return 0
  else
     return 1
  fi
}

get_json(){
  JSONVALUE=$(cat "$JSONFILE")
  if [ $? -eq 0 ]; then
     return 0
  else
     return 1
  fi
}

name_firstupdate(){
  get_rand
  get_json
  cmd="namecoin-cli -datadir=$DATADIR name_firstupdate $NAME $SHORTHEX $LONGHEX '${JSONVALUE}' > $FIRSTUFILE"
  eval $cmd
  cat $FIRSTUFILE
}

name_update(){
  get_json
  cmd="namecoin-cli -datadir=$DATADIR name_update $NAME $SHORTHEX '${JSONVALUE}' > $UPDATEFILE"
  eval $cmd
  cat $UPDATEFILE
}

name_new(){
  cmd="namecoin-cli -datadir=$DATADIR name_new $NAME > $NEWFILE"
  eval $cmd
  cat $NEWFILE
}

name_show(){
 result=$(namecoin-cli -datadir=$DATADIR name_show $NAME) &> /dev/null
 if [ $? -eq 0 ]; then
    expired=$(echo $result | python -c "import sys, json; print json.load(sys.stdin)['expired']")
    [[ $expired == "True" || $expired == "true" ]] &&  return 1 || return 0
 else
    return 1 
 fi
}

get_rand(){
  str=$(cat "$NEWFILE")
  array=(${str})
  LONGHEX=${array[1]}
  LONGHEX="${LONGHEX:1:${#LONGHEX}-3}"
  SHORTHEX=${array[2]}
  SHORTHEX="${SHORTHEX:1:${#SHORTHEX}-2}"
}

check_file(){
  FILE="$1"
  if [ ! -s $FILE ]; then
     return 1
  else
     return 0
  fi
}

get_confirmations(){
  get_rand
  result="" 
  result=$(namecoin-cli -datadir=$DATADIR gettransaction "$LONGHEX")
  CONF=$(echo $result | python -c "import sys, json; print json.load(sys.stdin)['confirmations']")
}

check_confirmations(){
  get_confirmations
  if [ "$CONF" -gt "$CONFMIN" ]; then
     return 0
  else
     return 1
  fi
}

# main

# VALIDATE ARGUMENTS
if [ $# -gt 2 ] || [ $# -eq 0 ] ; then
   echo ""
   echo "Usage: ${0} '<namespace/name>' [--update]"
   echo ""
   echo "<namespace/name>, Namecoin name"
   echo "[--update], update a registered name"
   echo ""
   exit 1
fi

# CHECK DATA DIR
if [ ! -d "$DATADIR" ] ; then
   echo "Specified data directory $DATADIR does not exist"
   exit 1
fi

# GET NAMESPACE/NAME
get_specName "$NAME"
if [ $? -ne 0 ] ; then
   echo "The name $NAME is invalid!"
   exit 1
fi

# CHECK NAME SIZE
check_size "$NMC_NAME"
if [ $? -ne 0 ] ; then
   echo "The name $NAME is invalid!"
   exit 1
fi

# VALIDATE DOMAIN
if [ "$NMC_SPEC" == "d/" ]; then
   check_domain "$NMC_NAME"
   if [ $? -ne 0 ] ; then
      echo "The name $NAME is not valid for a .bit domain!"
      exit 1
   fi
fi

# UPDATE NAME
if [ "$UPDATE" == "--update" ] ; then
   name_show
   if [ $? -ne 0 ] ; then
      echo "The name $NAME is not registered or expired!"
      exit 1
   fi
   check_file $JSONFILE
   if [ $? -ne 0 ] ; then
      echo "Missing $JSONFILE file!"
      exit 1
   fi
   check_json
   if [ $? -ne 0 ] ; then
      echo "$JSONFILE file is invalid!"
      exit 1
   fi 
   echo "Update name $NAME"
   name_update
   exit 0
fi

# PRE-ORDER & REGISTER NAME
name_show
if [ $? -eq 0 ] ; then
    echo "The name $NAME is alredy registered!"
    exit 1
else
    echo "The name $NAME is not registered or expired!"
fi
check_file $NEWFILE
if [ $? -eq 0 ] ; then
    check_confirmations
    if [ $? -eq 0 ]; then       	
       echo "Already pre-ordered, $CONF confirmations"
    else   
       echo "Already pre-ordered, $CONF confirmations"
       echo "Insuficient number of confirmations ( Min. = $CONFMIN )"
       echo "Try again later!" 
       exit 1  
    fi
    echo "Registering name $NAME"
    echo "Using file $NEWFILE"
    check_file $JSONFILE
    if [ $? -ne 0 ] ; then
       echo "Missing $JSONFILE file!"
       exit 1
    fi
    check_json
    if [ $? -ne 0 ] ; then
       echo "$JSONFILE file is invalid!"
       exit 1
    fi
    check_file $JSONFILE
    echo "Using file $JSONFILE"
    name_firstupdate 
    exit 0
else
    echo "Pre-ordering name $NAME ..."
    echo "This will reserve the name $NAME but not make it visible yet." 
    echo "Wait at least 12 blocks, then run this script again to update your name."
    echo ""
    name_new 
    exit 0
fi

exit 0
