#!/bin/bash
# Author: zhaowei <wei.zhao1@busonline.com>
# description: An example of notify script
#
vip=10.147.255.24
contact='weizhao@jieyuechina.com'
notify() {
    mailsubject="`hostname` to be $1: $vip floating"
    mailbody="`date '+%F %H:%M:%S'`: vrrp transition, `hostname` changed to be $1"
    echo $mailbody | mail -s "$mailsubject" $contact
}
case "$1" in
    master)
        notify master
        systemctl start haproxy
        exit 0
    ;;
    backup)
        notify backup
        systemctl start haproxy
        exit 0
    ;;
    fault)
        notify fault
        systemctl start haproxy
        exit 0
    ;;
    *)
        echo 'Usage: `basename $0` {master|backup|fault}'
        exit 1
    ;;
esac
