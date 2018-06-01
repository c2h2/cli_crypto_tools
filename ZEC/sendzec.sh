#!/bin/sh
echo "$1 $2" >> zec_send_log.txt
~/zcash/src/zcash-cli sendmany "" {\"$1\":$2}
