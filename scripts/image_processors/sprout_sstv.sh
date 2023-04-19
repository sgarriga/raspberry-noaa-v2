#!/bin/bash
#
# Purpose: Produce SPROUT SSTV files given input .wav file and specified output file dir.
#
# Input parameters:
#   1. Input .wav file
#   2. Desired output .png file dir
#
# Example:
#   ./sprout_sstv.sh /path/to/inputfile.wav /path/to/inputfile.png

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
IN_WAV_FILE=$1
OUT_PNG_FILE=$2

/usr/local/bin/sstv -d "${IN_WAV_FILE}" "${OUT_PNG_FILE}"

