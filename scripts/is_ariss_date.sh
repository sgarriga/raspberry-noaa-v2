#!/bin/bash
#
# Check to see if this is an ARISS SSTV Broadcast date
#
# Parameters
# $1 Epoch start date (ms)
# $2 Epoch end date (ms) - not the duration!
#
# It is assumed that a pass will not exceed 24 hours, but a pass may straddle 0000hrs 
#
# Usage: is_ariss_date.sh 1679363592 1679366889

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# Convert the epoc times to a UTC date
utc_ss="TZ=\"UTC\" @$1"
utc_es="TZ=\"UTC\" @$2"
utc_date_s=`date --date="$utc_ss" +%F`
utc_date_e=`date --date="$utc_es" +%F`

# log "Checking dates $1 ($utc_date_s UTC) and $2 ($utc_date_e UTC)" "DEBUG"

# Look for either of those dates in the config file
match=$(grep -m 1 -E "^${utc_date_s}|^${utc_date_e}" $HOME/.ariss_dates)
if [ ! -z "$match" ]; then
    log "ARISS Schedule date : $match" "DEBUG"
    exit 0
else
    if [ $utc_date_s == $utc_date_e ]; then
        log "$utc_date_s is not an ARISS SSTV date" "DEBUG"
    else
        log "$utc_date_s & $utc_date_e are not ARISS SSTV dates" "DEBUG"
    fi
    exit 1
fi
