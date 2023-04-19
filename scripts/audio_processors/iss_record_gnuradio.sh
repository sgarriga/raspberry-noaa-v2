#!/bin/bash
#
# Purpose: Record ISS SSTV audio via gnuradio to a wav file.
#
# Inputs:
#   1. ISS Module name 'ZARYA' - not currently used but arg retained to match pattern
#   2. capture_time: Time (in seconds) for length capture
#   3. out_wav_file: fully-qualified filename for output wav file, including '.wav' extension
#
# Example (record SSTV audio at for 15 seconds, output to /srv/audio/noaa/ZARYA.wav):
#   ./iss_record_gnuradio.sh 15 /srv/audio/noaa/ZARYA.wav

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

log "Recording ${NOAA_HOME} at ${ISS_SSTV_FREQ} MHz...to " "INFO"
log "Starting rtlsdr_iss_apt_rx.py ${OUT_FILE} Gain: ${GAIN} Frequency: ${ISS_SSTV_FREQ}M Offset: ${FREQ_OFFSET} Device: ${SDR_DEVICE_ID} Bias Tee: ${BIAS_TEE}" "INFO"
timeout "${CAPTURE_TIME}" "$NOAA_HOME/scripts/audio_processors/rtlsdr_iss_apt_rx.py" "${OUT_FILE}" "${GAIN}" "${ISS_SSTV_FREQ}"M "${FREQ_OFFSET}" "${SDR_DEVICE_ID}" "${BIAS_TEE}" >> $NOAA_LOG 2>&1

