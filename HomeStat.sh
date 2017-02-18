#!/bin/sh
# HomeStat application - targets Omega2
# Logs WLAN, INET, and A/C Power failures
# and creates a web page to display the log.

# HomeStat.conf contains definitions for:
#  LOG_FILE        Full path to the output log
#  HEARTBEAT_FILE  Full path to the heartbeat file
#  WEB_TEMPLATES   Directory containing page.top and page.bottom
#  WEB_PAGE        Full path to regularly regenerated page
#  INET_ADDRESS    IP address to ping for inet access test
#  PING_COUNT      -c parameter for ping command
#  LOOP_DELAY      Delay for each loop

SCRIPT_NAME=$(basename $0)
WLAN_ADDRESS=`route -n | grep 'UG[ \t]' | awk '{print $2}'`
INET_STATUS=-1
WNET_STATUS=-1


# Load the configuration file
# Script will fail and return error if config file isn't found
function Config {
  source "$(dirname $0)/HomeStat.conf"
  LOG_DIR="$(dirname $LOG_FILE)"
  if [ ! -d "$LOG_DIR" ]; then
    mkdir $LOG_DIR
  fi
}

# Call with param = 0, 1 or 2; results of ping
# Sets $STATUS_WORD
function StatusWord {
  STATUS_WORD=$1
  case $1 in
    0) STATUS_WORD="Connected" ;;
    1) STATUS_WORD="Disconnected" ;;
    2) STATUS_WORD="Error" ;;
    *)
  esac
}

# No parameters, sets $NOW
function Now {
  NOW=`date -Iseconds`
  NOW=${NOW:0:19}
  NOW=${NOW/T/ }
  NOW=${NOW//-/.}
}

# Make a web page (WEB_PAGE) from the log, heartbeat, and static files
# Side effect: Creates or overwrites WEB_PAGE
function MakeWebPage {
  cat $WEB_TEMPLATES/page.top > $WEB_PAGE
  cat $LOG_FILE $HEARTBEAT_FILE >> $WEB_PAGE
  cat $WEB_TEMPLATES/page.bottom >> $WEB_PAGE
}


# Load the configuration file
Config

# Pause to ensure date command is valid if started from rc.local
sleep 10

Now
if [ -e $HEARTBEAT_FILE ]; then
  cat $HEARTBEAT_FILE >> $LOG_FILE
  echo "$NOW  $SCRIPT_NAME Restart" >> $LOG_FILE
else
  echo "$NOW  $SCRIPT_NAME Startup" >> $LOG_FILE
fi

# Loop forever
while [ 1 ]
do
  Now
  echo "$NOW  Last Operation." > $HEARTBEAT_FILE
  ping -q -c $PING_COUNT $WLAN_ADDRESS &> /dev/null
  WNET=$?
  ping -q -c $PING_COUNT $INET_ADDRESS &> /dev/null 
  INET=$?

  if [ $INET_STATUS != $INET ]; then
    INET_STATUS=$INET
    StatusWord $INET
    echo "$NOW  INet status change: $STATUS_WORD" >> $LOG_FILE
  fi  
  if [ $WNET_STATUS != $WNET ]; then
    WNET_STATUS=$WNET
    StatusWord $WNET
    echo "$NOW  Wifi status change: $STATUS_WORD" >> $LOG_FILE
  fi
  MakeWebPage
  sleep $LOOP_DELAY
done

