#!/bin/sh
# HomeStat application - targets Omega2
# Logs WLAN, INET, and A/C Power failures
# and creates a web page to display the log.

BASEDIR=$(dirname $0)
LOGDIR="$BASEDIR/logs"
LOG_FILE="$LOGDIR/stat.log" 
HEARTBEAT_FILE="$LOGDIR/stat.heartbeat"
WEB_TEMPLATES="$BASEDIR/web"
WEB_PAGE="/www/HomeStat.html"

WLAN_ADDRESS=`route -n | grep 'UG[ \t]' | awk '{print $2}'`
INET_ADDRESS="8.8.8.8"
INET_STATUS=-1
WNET_STATUS=-1

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

# Pause to ensure date is valid
sleep 10
Now
if [ -e $HEARTBEAT_FILE ]; then
  cat $HEARTBEAT_FILE >> $LOG_FILE
  echo "$NOW  $(basename $0) Restart" >> $LOG_FILE
else
  echo "$NOW  $(basename $0) Startup" >> $LOG_FILE
fi

# Loop forever
while [ 1 ]
do
  Now
  echo "$NOW  Last Operation." > $HEARTBEAT_FILE
  ping -q -c 1 $WLAN_ADDRESS &> /dev/null
  WNET=$?
  ping -q -c 1 $INET_ADDRESS &> /dev/null 
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
  sleep 30
done

