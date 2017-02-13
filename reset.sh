#!/bin/sh
# delete the stat.log, stat.heartbeat, web page and restart the computer

BASEDIR=$(dirname $0)

rm /www/HomeStat.html
rm $BASEDIR/logs/stat.log
rm $BASEDIR/logs/stat.heartbeat
reboot

