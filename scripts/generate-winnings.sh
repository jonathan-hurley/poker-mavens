#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common-db.sh"

DATE=`date "+Generated on %B %d, %Y"`

# generate for cash
CASH_TABLE_BODY=""
echo "========= CASH SUMMARY ========="
for PLAYER in "${PLAYERS[@]}"
do
  # get player cash total from DB
  PLAYER_CASH_TOTAL=$(getPlayerCashTotalFromDB "$PLAYER")

  if [[ $PLAYER_CASH_TOTAL == 0 ]]; then
    echo "$PLAYER: \$0.00"
    continue
  fi

  echo "$PLAYER: \$$PLAYER_CASH_TOTAL"

  PLAYER_FOLDED_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "folded_hands_cash")
  PLAYER_SHOWN_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "shown_hands_cash")
  PLAYER_REFUNDED_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "refunded_hands_cash")
  TOTAL_PLAYER_HANDS_DEALT_CASH=$(($PLAYER_FOLDED_HANDS_CASH + $PLAYER_SHOWN_HANDS_CASH + $PLAYER_REFUNDED_HANDS_CASH))

  if [[ $PLAYER_CASH_TOTAL == "(redacted)" ]]; then
    PLAYER_PPH=$PLAYER_CASH_TOTAL
  else
    PLAYER_PPH=$(bc <<< "scale=4; x = $PLAYER_CASH_TOTAL / ($TOTAL_PLAYER_HANDS_DEALT_CASH / 100); scale = 2; x / 1")
  fi

  ROW_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 winnings-cell\">$PLAYER</td>
                        <td class=\"cell100 winnings-cell\"><span class="currency">$PLAYER_CASH_TOTAL</span></td>
                        <td class=\"cell100 winnings-cell\"><span class="currency">$PLAYER_PPH</span></td>
                      </tr>
"
  CASH_TABLE_BODY="$CASH_TABLE_BODY $ROW_TEMPLATE"
done

echo -e "\n========= TOURNAMENT GROSS ========="

# now generate for tournament
TOURNAMENT_TABLE_BODY=
for PLAYER in "${PLAYERS[@]}"
do
  # if the player has never entered a tournament, skip them
  PLAYER_NUMBER_OF_TOURNAMENTS=$(getPlayerStatFromDB "$PLAYER" "tournaments_entered")
  if [[ $PLAYER_NUMBER_OF_TOURNAMENTS == 0 ]]; then
    echo "$PLAYER: \$0 (0)"
    continue
  fi

  # first calculate buy-ins spent
  BUY_IN_TOTAL=$(getPlayerStatFromDB "$PLAYER" "tournament_total_spent")

  # calculate tournament winnings
  PLAYER_TOURNAMENT_WINNINGS=$(getPlayerStatFromDB "$PLAYER" "tournament_gross_winnings")
  OFFSET=$(getPlayerStatFromDB "$PLAYER" "offset_tournament_winnings")
  PLAYER_TOURNAMENT_WINNINGS=`bc <<< "$OFFSET + $PLAYER_TOURNAMENT_WINNINGS"`  

  PLAYER_TOURNAMENT_CASHES=$(getPlayerStatFromDB "$PLAYER" "tournament_cashes")
  OFFSET=$(getPlayerStatFromDB "$PLAYER" "offset_tournament_num_cashes")
  PLAYER_TOURNAMENT_CASHES=`bc <<< "$OFFSET + $PLAYER_TOURNAMENT_CASHES"`  

  if [[ -z $PLAYER_TOURNAMENT_WINNINGS ]]; then
    PLAYER_TOURNAMENT_WINNINGS=0
  fi

  PLAYER_PROFIT=$(bc <<< "scale=4; x = $PLAYER_TOURNAMENT_WINNINGS - $BUY_IN_TOTAL; scale = 2; x / 1")
  PLAYER_ROI=$(bc <<< "scale=4; x = $PLAYER_PROFIT / $BUY_IN_TOTAL * 100; scale = 2; x / 1")

  # standardize on 2 decimal places
  PLAYER_TOURNAMENT_WINNINGS=$(printf "%0.2f" $PLAYER_TOURNAMENT_WINNINGS)
  PLAYER_PROFIT=$(printf "%0.2f" $PLAYER_PROFIT)
  PLAYER_ROI=$(printf "%0.2f" $PLAYER_ROI)

  echo "$PLAYER: \$$PLAYER_TOURNAMENT_WINNINGS ($PLAYER_TOURNAMENT_CASHES)"

  ROW_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 winnings-cell\">$PLAYER</td>
                        <td class=\"cell100 winnings-cell\"><span class=\"currency\">$PLAYER_TOURNAMENT_WINNINGS</span></td>
                        <td class=\"cell100 winnings-cell\"><span class=\"currency\">$PLAYER_PROFIT</span></td>
                        <td class=\"cell100 winnings-cell\">$PLAYER_TOURNAMENT_CASHES</td>
                        <td class=\"cell100 winnings-cell\"><span class=\"percentage\">$PLAYER_ROI</span></td>
                      </tr>
"
  TOURNAMENT_TABLE_BODY="$TOURNAMENT_TABLE_BODY $ROW_TEMPLATE"
done

FINAL=$(awk -v r="$CASH_TABLE_BODY" '{gsub(/_CASH_TABLE_BODY_/,r)}1' templates/winnings.html)
FINAL="${FINAL/_GENERATED_ON_/$DATE}"
FINAL="${FINAL//_POKER_SITE_NAME_/$POKER_SITE_NAME}"
FINAL="${FINAL/_TOURNAMENT_TABLE_BODY_/$TOURNAMENT_TABLE_BODY}"
echo "$FINAL" > web/results-winnings.html

echo ""
