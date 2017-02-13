#!/bin/sh
# Create a web page from log and heartbeat and write to $WEB_PAGE

WEB_PAGE="/www/HomeStat.html"
BASEDIR=$(dirname $0)

cat $BASEDIR/web/page.top > $WEB_PAGE
cat $BASEDIR/logs/stat.log $BASEDIR/logs/stat.heartbeat >> $WEB_PAGE
cat $BASEDIR/web/page.bottom >> $WEB_PAGE

