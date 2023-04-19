#!/bin/bash
#
# Purpose: Produce ARISS SSTV files given input .wav file and specified output file dir.
#
# Input parameters:
#   1. Input .wav file
#   2. Desired output .png file dir
#
# Example:
#   ./iss_sstv.sh /path/to/inputfile.wav /path/to/
# Results will be inputfile1.png inputfile2.png ...

# import common lib and settings
. "$HOME/.noaa-v2.conf"
. "$NOAA_HOME/scripts/common.sh"

# input params
IN_WAV_FILE=$1
OUT_PNG_DIR=$2

python3 "$ISS_SSTV_PROC_DIR/demod.py" "${IN_WAV_FILE}" "${OUT_PNG_DIR}"

