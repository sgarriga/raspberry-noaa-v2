#!/bin/bash
#
# Check to see if this is an SPROUT SSTV Broadcast date
#
# Parameters
# $1 Epoch start date (ms)
# $2 Epoch end date (ms) - not the duration!
#
# It is assumed that a pass will not exceed 24 hours, but a pass may straddle 0000hrs 
#
# Usage: is_sprout_date.sh 1679363592 1679366889

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# log "$0 $1 $2" "DEBUG"

# Convert the epoc times to a UTC date
jst_ss="TZ=\"Asia/Tokyo\" @$1"
jst_es="TZ=\"Asia/Tokyo\" @$2"
jst_dow_s=`date --date="$jst_ss" +%w`
jst_dow_e=`date --date="$jst_es" +%w`

if [ $jst_dow_s -eq 0 ]; then
    log "Sunday start - SPROUT SSTV possible" "DEBUG"
    exit 0
fi
if [ $jst_dow_e -eq 0 ]; then
    log "Sunday end - SPROUT SSTV possible" "DEBUG"
    exit 0
fi

log "Not Sunday - No SPROUT SSTV" "DEBUG"
exit 1
