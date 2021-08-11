#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/../common.sh"
. "$DIR/generate-plot-data.sh"

# create temporary files
LOCKDOWN_TMP=$(mktemp /tmp/lockdown.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
LOCKDOWN_PLOT_DATA_TMP=$(mktemp /tmp/lockdown-plot-data.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
SMACKDOWN_TMP=$(mktemp /tmp/smackdown.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }
SMACKDOWN_PLOT_DATA_TMP=$(mktemp /tmp/smackdown-plot-data.XXXXXXXXXX) || { echo "Failed to create temp file"; exit 1; }

# find all table files for most recent game for both Lockdown and Smackdown games
LOCKDOWN_TOURNAMENT_FILE_PATTERN=`ls -Art $PM_DATA_HAND_HISTORY_DIR/*Lockdown* | tail -n 1 | grep -o "HH.*Lockdown"`
LOCKDOWN_TOURNAMENT_FILE_PATTERN="${LOCKDOWN_TOURNAMENT_FILE_PATTERN}*"
SMACKDOWN_TOURNAMENT_FILE_PATTERN=`ls -Art $PM_DATA_HAND_HISTORY_DIR/*Smackdown* | tail -n 1 | grep -o "HH.*Smackdown"`
SMACKDOWN_TOURNAMENT_FILE_PATTERN="${SMACKDOWN_TOURNAMENT_FILE_PATTERN}*"

# dump all table files to a temp file and get sorted timestamp
find $PM_DATA_HAND_HISTORY_DIR/ -name "$LOCKDOWN_TOURNAMENT_FILE_PATTERN" -exec cat "{}" >> "$LOCKDOWN_TMP" +
LOCKDOWN_SORTED_HANDS=`egrep -h -e "Hand" $LOCKDOWN_TMP | awk '{print $4 " " $5}' | sort`
find $PM_DATA_HAND_HISTORY_DIR/ -name "$SMACKDOWN_TOURNAMENT_FILE_PATTERN" -exec cat "{}" >> "$SMACKDOWN_TMP" +
SMACKDOWN_SORTED_HANDS=`egrep -h -e "Hand" $SMACKDOWN_TMP | awk '{print $4 " " $5}' | sort`

generatePlotData "$LOCKDOWN_TMP" "$LOCKDOWN_SORTED_HANDS" "$LOCKDOWN_PLOT_DATA_TMP"
generatePlotData "$SMACKDOWN_TMP" "$SMACKDOWN_SORTED_HANDS" "$SMACKDOWN_PLOT_DATA_TMP"

scripts/stack-size.plot "$LOCKDOWN_PLOT_DATA_TMP" "$SMACKDOWN_PLOT_DATA_TMP" > web/images/stack-sizes.svg
scripts/stack-size-single-canvas.plot "$LOCKDOWN_PLOT_DATA_TMP" Lockdown > web/stack-sizes-lockdown.html
scripts/stack-size-single-canvas.plot "$SMACKDOWN_PLOT_DATA_TMP" Smackdown > web/stack-sizes-smackdown.html

rm "$LOCKDOWN_TMP"
rm "$LOCKDOWN_PLOT_DATA_TMP"
rm "$SMACKDOWN_TMP"
rm "$SMACKDOWN_PLOT_DATA_TMP"
