#!/bin/bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.sh"

# Convert the Poker Mavens data into a CSV that can be consumed by gnuplot
function generatePlotData(){
  if [[ $# -ne 3 ]]; then
      echo "Illegal number of parameters"
  fi

  TMP_HAND_HISTORY=$1
  SORTED_HANDS=$2
  PLOT_DATA_TMP=$3

  echo "Generating data from $TMP_HAND_HISTORY for $PLOT_DATA_TMP"

  ALL_PLAYER_DATA=
  for PLAYER in "${PLAYERS[@]}"; do
    PLAYER_DATA=

    PLAYER_EXISTS_REGEX="Seat [0-9]+: "$PLAYER" \([0-9]+\)"
    PLAYER_EXISTS=$(cat $TMP_HAND_HISTORY | pcregrep -M "$PLAYER_EXISTS_REGEX")
    if [ -z "$PLAYER_EXISTS" ]; then
      continue
    fi

    while IFS= read -r HAND_TIME; do
      HAND_REGEX="Hand.*"$HAND_TIME"(?:.|\n)*?(?:\h*\n){2,}"
      PLAYER_STACK_REGEX="Seat \d+: "$PLAYER" \(\d+\)"
      HAND=`pcregrep -M "$HAND_REGEX" $TMP_HAND_HISTORY`
      PLAYER_STACK_SIZE=`grep -P "$PLAYER_STACK_REGEX" <<< "$HAND" | awk '{print $4}' | tr -d '()'`
      if [ -z "$PLAYER_STACK_SIZE" ]; then
        continue
      fi

      PLAYER_DATA="$PLAYER_DATA"$'\n'"$PLAYER_STACK_SIZE"
    done <<< "$SORTED_HANDS"

    if [ -z "$PLAYER_DATA" ]; then
      continue
    fi

    if [ -z "$ALL_PLAYER_DATA" ]; then
      ALL_PLAYER_DATA="$PLAYER""$PLAYER_DATA"$'\n'$'\n'
    else
      ALL_PLAYER_DATA="$ALL_PLAYER_DATA"$'\n'"$PLAYER""$PLAYER_DATA"$'\n'$'\n'
    fi
  done

  echo -en "$ALL_PLAYER_DATA" >> "$PLOT_DATA_TMP"
}
