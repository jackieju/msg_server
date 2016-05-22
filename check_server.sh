#!/bin/bash

# # crontab:
# 02 4 * * * ju.weihua /bin/sh /var/www/msg_server/check_server.sh >/dev/null 2>&1

cd /var/www/msg_server/
./restart_gserver