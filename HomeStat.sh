#!/bin/sh
# HomeStat application - targets Omega2
# Logs WLAN, INET, and A/C Power failures
# and creates a web page to display the log.

INET_STATUS=-1
WNET_STATUS=-1
BASEDIR=$(dirname $0)
LOG_FILE="$BASEDIR/logs/stat.log" 
HEARTBEAT_FILE="$BASEDIR/logs/stat.heartbeat"

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
}

# Pause to ensure date is valid
sleep 10
Now
if [ -e $HEARTBEAT_FILE ]; then
  cat $HEARTBEAT_FILE >> $LOG_FILE
  echo "$NOW: $(basename $0) Restart" >> $LOG_FILE
else
  echo "$NOW: $(basename $0) Startup" >> $LOG_FILE
fi

# Loop forever
while [ 1 ]
do
  Now
  echo "$NOW: Last Operation." > $HEARTBEAT_FILE
  ping -q -c 1 192.168.1.1 &> /dev/null
  WNET=$?
  ping -q -c 1 8.8.8.8 &> /dev/null 
  INET=$?

  if [ $INET_STATUS != $INET ]; then
    INET_STATUS=$INET
    StatusWord $INET
    echo "$NOW: iNet status change: $STATUS_WORD" >> $LOG_FILE
  fi  
  if [ $WNET_STATUS != $WNET ]; then
    WNET_STATUS=$WNET
    StatusWord $WNET
    echo "$NOW: Wifi status change: $STATUS_WORD" >> $LOG_FILE
  fi
  $BASEDIR/MakePage.sh
  sleep 30
done

