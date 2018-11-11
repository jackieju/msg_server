#!/bin/sh
# pwd = `pwd`
d=`date`
d=$d":check_server"$*
echo $d
echo $d >> /var/wh/log/check_msg_server
pwd="/var/www/msg_server"
echo $pwd
echo $*
# echo cd $pwd && $*
# cd $pwd && $*
cd $pwd
pwd
sh $*