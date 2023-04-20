#!/bin/bash
#
# Purpose: Purges (removes) all DB records for capture files older than $PRUNE_OLDER_THAN days old, and
#          all images/files on disk regardless of presence in DB

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

#Generate date since epoch in seconds - days
let prunedate=$(date +%s)-$PRUNE_OLDER_THAN*24*60*60
sqlite3 "${DB_FILE}" "delete from decoded_passes where pass_start < $prunedate;"

#Regardless if DB entry, purge ALL files 
find ${IMAGE_OUTPUT} -mtime ${PRUNE_OLDER_THAN} -type f -delete
find ${NOAA_AUDIO_OUTPUT} -mtime ${PRUNE_OLDER_THAN} -type f -delete
find ${METEOR_AUDIO_OUTPUT} -mtime ${PRUNE_OLDER_THAN} -type f -delete
find ${SSTV_AUDIO_OUTPUT} -mtime ${PRUNE_OLDER_THAN} -type f -delete


