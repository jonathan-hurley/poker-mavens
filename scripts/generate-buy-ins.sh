#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common-db.sh"

echo ""
echo "========= TOURNAMENT SPENDING ========="

for PLAYER in "${PLAYERS[@]}"
do
  TOTAL=$(getPlayerStatFromDB "$PLAYER" "tournament_total_spent")
  printf "%s has spent $%'.0f\n" $PLAYER $TOTAL
done
echo ""