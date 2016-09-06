#!/bin/bash 
###############################################################################
#
# Script to register .bit domains
#
# How to use:
# 1 - Install and configure the namecoin software
# https://wiki.namecoin.org/index.php?title=Install_and_Configure_Namecoin
# 2 - Print your namecoin wallet address using the command:
# namecoind listreceivedbyaddress 0 true 
# 3 - Transfer namecoins (NMC) to your wallet using an exchage
# https://namecoin.org/?p=exchanges 
# 4 - Create a JSON-encoded file (<name>.json) with nameserver information 
# for the domain
# http://dot-bit.org/Namespace:Domain_names_v2.0
# 5 - Run this script 
# ./register_bit_domain.sh <name>
# <name> is your domain name without .bit, in lowercase.
# 
# Example: to register example.bit domain, 1st create the example.json 
# file with nameserver information and run:
# ./register_bit_domain.sh 'example'
#
# 6 - Wait at least 12 blocks, which is generally between 2  and 6 hours 
# (depending on how active the network is), then update your domain by 
# running the script again:
# ./register_bit_domain.sh '<name>'
#
#
# authors:
# Jose Faisca <jose.faisca@gmail.com>
#
###############################################################################

NAME="$1" 			# domain name argument
UPDATE="$2"			# update domain argument 
RAND="" 			# short hex number
LONGHEX="" 			# longer hex code
CONF=0 				# blocks / confirmations
CONFMIN=12 			# minimum blocks before first update
JSONFILE="$NAME.json" 		# JSON file with nameserver information
NEWFILE="$NAME.new" 		# output of name_new command
FIRSTUFILE="$NAME.firstupdate" 	# output of name_firstupdate command
UPDATEFILE="$NAME.update"	# output of name_update command

check_domain(){
 domain=$1
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
  cmd="namecoind name_firstupdate d/$NAME $RAND $LONGHEX '${JSONVALUE}' > $FIRSTUFILE"
  eval $cmd
  cat $FIRSTUFILE
}

name_update(){
  get_json
  cmd="namecoind name_update d/$NAME $RAND '${JSONVALUE}' > $UPDATEFILE"
  eval $cmd
  cat $UPDATEFILE
}

name_new(){
  cmd="namecoind name_new d/$NAME > $NEWFILE"
  eval $cmd
  cat $NEWFILE
}

name_show(){
  { 
  namecoind name_show d/$NAME 
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
 result=$(namecoind listtransactions | grep -B 1 -A 0 "$LONGHEX")
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
   echo "<name> is your domain name without .bit, in lowercase"
   echo "use --update to update a registered domain" 
   echo ""
   exit 1
fi

# VALIDATE DOMAIN
check_domain "$NAME"
if [ $? -ne 0 ] ; then
        echo "The domain $NAME.bit is invalid!"
        echo ".. EXIT .."
        exit 1
fi

# UPDATE DOMAIN 
if [ "$UPDATE" == "--update" ] ; then
  name_show
  if [ $? -ne 0 ] ; then
   	echo "The domain $NAME.bit is not registered!"
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
  echo "Update domain $NAME.bit"
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

# PRE-ORDER & REGISTER DOMAIN
name_show
if [ $? -eq 0 ] ; then
  echo "The domain $NAME.bit is alredy registered!"
  echo ".. EXIT .."
  exit 1
else
  echo "The domain $NAME.bit is not registered!"
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
  echo "Registering domain $NAME.bit"
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
  echo "Pre-ordering domain $NAME.bit"
  read -p "Continue (y/n)? " choice
  case "$choice" in 
  	y|Y ) echo "yes";;
  	n|N ) echo ".. EXIT .." && exit 1;;
  	* ) echo "invalid option" && exit 1;;
  esac
  echo "This will reserve the domain $NAME.bit but not make it visible yet." 
  echo "Wait at least 12 blocks, which is generally between 2 and 6 hours " 
  echo "then run this script again to update your domain."
  echo ""
  echo "DO NOT SHUTDOWN namecoind"
  echo ""
  echo "Running ..."
  name_new && echo ".. DONE .."
  exit 0
fi

exit 0
