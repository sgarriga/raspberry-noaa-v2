#!/bin/bash
#
# Purpose: Receive and process ISS SSTV captures.
#
# Input parameters:
#   1. Name of ISS module (i.e. "ZARYA")
#   2. Filename of image outputs
#   3. TLE file location
#   4. Epoch start time for capture
#   5. Duration of capture (seconds)
#   6. Max angle elevation for satellite
#   7. Direction of pass
#   8. Side of pass (W=West, E=East) relative to base station
#
# Example:
#   ./receive_iss.sh "ZARYA" ZARYA20210208-194829 ./orbit.tle 1612831709 919 31 Southbound E

# time keeping
TIMER_START=$(date '+%s')

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"
capture_start=$START_DATE

# input params
export SAT_NAME=$1
export FILENAME_BASE=$2
export TLE_FILE=$3
export EPOCH_START=$4
export CAPTURE_TIME=$5
export SAT_MAX_ELEVATION=$6
export PASS_DIRECTION=$7
export PASS_SIDE=$8

export GAIN=$ISS_SSTV_GAIN
export SUN_MIN_ELEV=$ISS_SSTV_SUN_MIN_ELEV
export SDR_DEVICE_ID=$ISS_SSTV_SDR_DEVICE_ID
if [ "$ISS_SSTV_ENABLE_BIAS_TEE" != "usb" ]; then
    export BIAS_TEE=$ISS_SSTV_ENABLE_BIAS_TEE
else
    export BIAS_TEE=""
fi
export FREQ_OFFSET=$ISS_SSTV_FREQ_OFFSET
export SAT_MIN_ELEV=$ISS_SSTV_SAT_MIN_ELEV

# base directory plus filename helper variables
AUDIO_FILE_BASE="${SSTV_AUDIO_OUTPUT}/${FILENAME_BASE}"

# pass start timestamp and sun elevation
PASS_START=$(expr "$EPOCH_START" + 90)
export SUN_ELEV=$(python3 "$SCRIPTS_DIR"/tools/sun.py "$PASS_START")

if pgrep "rtl_fm" > /dev/null; then
  log "There is an existing rtl_fm instance running, I quit" "ERROR"
  exit 1
fi

log "Receive ISS SSTV Processes starting...." "INFO"

if [ "$ISS_SSTV_ENABLE_BIAS_TEE" == "usb" ]; then
    # turn on rtl-sdr v3.0 bias tee
    rtl_biast -b 1
fi

if [ "$NOAA_RECEIVER" == "rtl_fm" ]; then
  log "Starting rtl_fm record" "INFO"
  ${AUDIO_PROC_DIR}/iss_record_rtl_fm.sh "${SAT_NAME}" $CAPTURE_TIME "${AUDIO_FILE_BASE}.wav" >> $NOAA_LOG 2>&1
fi
if [ "$NOAA_RECEIVER" == "gnuradio" ]; then
  log "Starting gnuradio record" "INFO"
  ${AUDIO_PROC_DIR}/iss_record_gnuradio.sh "${SAT_NAME}" $CAPTURE_TIME "${AUDIO_FILE_BASE}.wav" >> $NOAA_LOG 2>&1
fi

if [ "$ISS_SSTV_ENABLE_BIAS_TEE" == "usb" ]; then
    # turn off rtl-sdr v3.0 bias tee
    rtl_biast -b 0
fi

# wait for files to close
sleep 5

${IMAGE_PROC_DIR}/iss_sstv.sh "${AUDIO_FILE_BASE}.wav" "${IMAGE_OUTPUT}" >> $NOAA_LOG 2>&1
decoded_pictures="$(find ${IMAGE_OUTPUT} -iname "${FILENAME_BASE}*png")"
img_count=0
for image in $decoded_pictures; do
    log "Decoded image: $image" "INFO"
    file=`echo $(image) | sed s?.*/??`
    ${IMAGE_PROC_DIR}/thumbnail.sh 300 "${image}" "${IMAGE_OUTPUT}/thumb/${file}" >> $NOAA_LOG 2>&1
    ((img_count++))
done

if [ $img_count -gt 0 ]; then
# store decoded pass
    $SQLITE3 $DB_FILE "INSERT OR REPLACE INTO decoded_passes (id, pass_start, file_path, daylight_pass, sat_type, has_spectrogram, has_polar_az_el, has_polar_direction, gain) \
                           VALUES ( \
                             (SELECT id FROM decoded_passes WHERE pass_start = $EPOCH_START), \
                             $EPOCH_START, \"$FILENAME_BASE\", 0, 0, 0, 0, 0, $GAIN \
                           );"

    pass_id=$($SQLITE3 $DB_FILE "SELECT id FROM decoded_passes ORDER BY id DESC LIMIT 1;")
    $SQLITE3 $DB_FILE "UPDATE predict_passes \
                           SET is_active = 0 \
                           WHERE (predict_passes.pass_start) \
                           IN ( \
                             SELECT predict_passes.pass_start \
                             FROM predict_passes \
                             INNER JOIN decoded_passes \
                             ON predict_passes.pass_start = decoded_passes.pass_start \
                             WHERE decoded_passes.id = $pass_id \
                           );"
else
  log "No images extracted" "ERROR"
fi

# handle Slack pushing if enabled
if [ "${ENABLE_SLACK_PUSH}" == "true" ]; then
  slack_push_annotation="ISS Slow Scan TV files"
  pass_id=$($SQLITE3 $DB_FILE "SELECT id FROM decoded_passes ORDER BY id DESC LIMIT 1;")
  slack_push_annotation="${slack_push_annotation} <${SLACK_LINK_URL}?pass_id=${pass_id}>\n";

  ${PUSH_PROC_DIR}/push_slack.sh "${slack_push_annotation}" $push_file_list
fi

# handle twitter pushing if enabled
if [ "${ENABLE_TWITTER_PUSH}" == "true" ]; then
  # create push annotation specific to twitter
  # note this is NOT the annotation on the image, which is driven by the config/annotation/annotation.html.j2 file
  slack_push_annotation="ISS Slow Scan TV files"

  ${PUSH_PROC_DIR}/push_twitter.sh "${twitter_push_annotation}" $push_file_list
fi

if [ "$DELETE_AUDIO" = true ]; then
  log "Deleting audio files" "INFO"
  rm "${AUDIO_FILE_BASE}.wav"
fi

# calculate and report total time for capture
TIMER_END=$(date '+%s')
DIFF=$(($TIMER_END - $TIMER_START))
PROC_TIME=$(date -ud "@$DIFF" +'%H:%M.%S')
log "Total processing time: ${PROC_TIME}" "INFO"

