#!/bin/bash 
###############################################################################
#
# Script to register Namecoin names
#
# How to use:
# 1 - Install and configure the namecoin software
# https://wiki.namecoin.org/index.php?title=Install_and_Configure_Namecoin
# 2 - Print your namecoin wallet address using the command:
# namecoind listreceivedbyaddress 0 true 
# 3 - Transfer namecoins (NMC) to your wallet using an exchage
# https://namecoin.org/?p=exchanges 
# 4 - Create a JSON-encoded file (<name>.json) with name information 
# 5 - Run this script 
# ./register-name.sh <name>
# <name> is your name, in lowercase.
# 
# Example: to register Bob id, 1st create the example.json 
# file with id information and run:
# ./register-name.sh 'id/Bob'
#
# 6 - Wait at least 12 blocks, which is generally between 2  and 6 hours 
# (depending on how active the network is), then update your name by 
# running the script again:
# ./register-name.sh '<name>'
#
#
# authors:
# Jose G. Faisca <jose.faisca@gmail.com>
#
###############################################################################

NAME="$1" 			# name argument
UPDATE="$2"			# update name argument 
RAND="" 			# short hex number
LONGHEX="" 			# longer hex code
CONF=0 				# blocks / confirmations
CONFMIN=12 			# minimum blocks before first update
JSONFILE="$NAME.json" 		# JSON file with nameserver information
NEWFILE="$NAME.new" 		# output of name_new command
FIRSTUFILE="$NAME.firstupdate" 	# output of name_firstupdate command
UPDATEFILE="$NAME.update"	# output of name_update command
DATADIR="$HOME/namecoin"	# Namecoin data directory

check_domain(){
 domain=$1
 domain="${domain:2}"
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
  cmd="namecoin-cli -datadir=$DATADIR name_firstupdate $NAME $RAND $LONGHEX '${JSONVALUE}' > $FIRSTUFILE"
  eval $cmd
  cat $FIRSTUFILE
}

name_update(){
  get_json
  cmd="namecoin-cli -datadir=$DATADIR name_update $NAME $RAND '${JSONVALUE}' > $UPDATEFILE"
  eval $cmd
  cat $UPDATEFILE
}

name_new(){
  cmd="namecoin-cli -datadir=$DATADIR name_new $NAME > $NEWFILE"
  eval $cmd
  cat $NEWFILE
}

name_show(){
  { 
  namecoin-cli -datadir=$DATADIR name_show $NAME 
  } &> /dev/null
 if [ $? -eq 0 ]; then
    return 0
 else
    return 1 
 fi
}

get_rand(){
  str=$(cat "$NEWFILE")
  array=(${str})
  LONGHEX=${array[1]}
  LONGHEX="${LONGHEX:1:${#LONGHEX}-3}"
  RAND=${array[2]}
  RAND="${RAND:1:${#RAND}-2}"
}

check_file(){
FILE="$1"
 if [ ! -f $FILE ]; then
   return 1
 else
   return 0
 fi
}

get_confirmations(){
 get_rand
 result="" 
 result=$(namecoin-cli -datadir=$DATADIR listtransactions | grep -B 1 -A 0 "$LONGHEX")
 IFS=': ' read -a array <<< $result
 CONF=${array[1]}
 CONF="${CONF//,}"
}

check_confirmations(){
  get_confirmations
  if [ $CONF -gt $CONFMIN ]; then
    return 0
  else
    return 1
  fi
}

# main

# VALIDATE ARGUMENTS
if [ $# -gt 2 ] || [ $# -eq 0 ] ; then
   echo ""
   echo "Usage: ${0} '<name>' [--update]"
   echo "<name> is your name, in lowercase"
   echo "use --update to update a registered name" 
   echo ""
   exit 1
fi

# VALIDATE DOMAIN
[ ${STR:0:2} = "d/" ] && check_domain "$NAME"
if [ $? -ne 0 ] ; then
        echo "The name $NAME is invalid for a .bit domain!"
        echo ".. EXIT .."
        exit 1
fi

# UPDATE NAME 
if [ "$UPDATE" == "--update" ] ; then
  name_show
  if [ $? -ne 0 ] ; then
   	echo "The name $NAME is not registered!"
  	echo ".. EXIT .."
  	exit 1
  fi
  check_file $JSONFILE
  if [ $? -ne 0 ] ; then
        echo "Missing $JSONFILE file!"
        echo ".. EXIT .."
        exit 1
  fi
  check_json
  if [ $? -ne 0 ] ; then
        echo "$JSONFILE file is invalid!"
        echo ".. EXIT .."
        exit 1
  fi 
  echo "Update name $NAME"
  read -p "Continue (y/n)? " choice
  case "$choice" in
        y|Y ) echo "yes";;
        n|N ) echo ".. EXIT .." && exit 1;;
        * ) echo "invalid option" && exit 1;;
  esac
  echo "Running ..."
  name_update && echo ".. DONE .."
  exit 0
fi

# PRE-ORDER & REGISTER NAME
name_show
if [ $? -eq 0 ] ; then
  echo "The name $NAME is alredy registered!"
  echo ".. EXIT .."
  exit 1
else
  echo "The name $NAME is not registered!"
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
   echo ".. EXIT .."
   exit 1  
  fi
  echo "Registering name $NAME"
  read -p "Continue (y/n)? " choice
  case "$choice" in
        y|Y ) echo "yes";;
        n|N ) echo ".. EXIT .." && exit 1;;
        * ) echo "invalid option" && exit 1;;
  esac
  echo "Using file $NEWFILE"
  check_file $JSONFILE
  if [ $? -ne 0 ] ; then
        echo "Missing $JSONFILE file!"
        echo ".. EXIT .."
        exit 1
  fi
  check_json
  if [ $? -ne 0 ] ; then
        echo "$JSONFILE file is invalid!"
        echo ".. EXIT .."
        exit 1
  fi
  check_file $JSONFILE
  echo "Using file $JSONFILE"
  echo "Running ..."
  name_firstupdate && echo ".. DONE .."
  exit 0
else
  echo "Pre-ordering name $NAME.bit"
  read -p "Continue (y/n)? " choice
  case "$choice" in 
  	y|Y ) echo "yes";;
  	n|N ) echo ".. EXIT .." && exit 1;;
  	* ) echo "invalid option" && exit 1;;
  esac
  echo "This will reserve the name $NAME.bit but not make it visible yet." 
  echo "Wait at least 12 blocks, which is generally between 2 and 6 hours " 
  echo "then run this script again to update your name."
  echo ""
  echo "DO NOT SHUTDOWN namecoin"
  echo ""
  echo "Running ..."
  name_new && echo ".. DONE .."
  exit 0
fi

exit 0
