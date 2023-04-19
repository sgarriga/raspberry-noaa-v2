#!/bin/bash
#
# Purpose: Record SPROUT SSTV audio via rtl_fm to a wav file.
# - This could probably be merged into the ISS SSTV version
#
# Inputs:
#   1. Satellite name 'SPROUT' - not used currently, but to maintain the args pattern
#   2. capture_time: Time (in seconds) for length capture
#   3. out_wav_file: fully-qualified filename for output wav file, including '.wav' extension

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
CAPTURE_TIME=$2
OUT_FILE=$3

# check that filename extension is wav (only type supported currently)
if [ ${OUT_FILE: -4} != ".wav" ]; then
  log "Output file must end in .wav extension." "ERROR"
  exit 1
fi

log "Recording at ${SPROUT_SSTV_FREQ} MHz..." "INFO"
if [ "${GAIN}" == 0 ]; then
    gain_info=""
else
    gain_info="-g ${GAIN}"
fi
timeout "${CAPTURE_TIME}" $RTL_FM -d ${SDR_DEVICE_ID} ${BIAS_TEE} -M fm -f "${SPROUT_SSTV_FREQ}"M -s 48k "${gain_info}" -E dc -E wav -E deemp -F 9 - | $SOX  -t raw -r 48k -c 1 -b 16 -e s - -t wav "${OUT_FILE}" rate 11025

