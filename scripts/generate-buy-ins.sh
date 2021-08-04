#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.sh"

echo -e "\n========= TOURNAMENT SPENDING ========="

for PLAYER in "${PLAYERS[@]}"
do
  TOTAL=$(calculatePlayerBuyInTotal "$PLAYER")
  printf "%s has spent $%'.0f\n" $PLAYER $TOTAL
done
