#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.sh"

DATE=`date "+Generated on %B %d, %Y"`

# generate for cash
CASH_TABLE_BODY=""
echo -e "\n========= CASH SUMMARY ========="
for PLAYER in "${PLAYERS[@]}"
do
  # calculate player cash total
  PLAYER_CASH_TOTAL=$(calculatePlayerCashTotal "$PLAYER")

  if [[ $PLAYER_CASH_TOTAL == 0 ]]; then
    echo "$PLAYER: \$0.00"
    continue
  fi

  # format the total
  PLAYER_CASH_TOTAL=$(printf "%0.2f" $PLAYER_CASH_TOTAL)

  echo "$PLAYER: \$$PLAYER_CASH_TOTAL"

  # format total

  ROW_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">$PLAYER</td>
                        <td class=\"cell100 stats-column2\"><span class="currency">$PLAYER_CASH_TOTAL</span></td>
                      </tr>
"
  CASH_TABLE_BODY="$CASH_TABLE_BODY $ROW_TEMPLATE"
done

echo -e "\n========= TOURNAMENT NET ========="

# now generate for tournament
TOURNAMENT_TABLE_BODY=
for PLAYER in "${PLAYERS[@]}"
do
  # first calculate buy-ins spent
  BUY_IN_TOTAL=$(calculatePlayerBuyInTotal "$PLAYER")

  # calculate tournament winnings
  PLAYER_TOURNAMENT_WINNINGS=$(calculatePlayerTournamentWinnings "$PLAYER")
  PLAYER_TOURNAMENT_CASHES=$(calculatePlayerNumberOfCashes $PLAYER)
  if [[ -z $PLAYER_TOURNAMENT_WINNINGS ]]; then
    PLAYER_TOURNAMENT_WINNINGS=0
  fi

  PLAYER_PROFIT=$(echo $PLAYER_TOURNAMENT_WINNINGS - $BUY_IN_TOTAL | bc)

  # standardize on 2 decimal places
  PLAYER_TOURNAMENT_WINNINGS=$(printf "%0.2f" $PLAYER_TOURNAMENT_WINNINGS)
  PLAYER_PROFIT=$(printf "%0.2f" $PLAYER_PROFIT)

  echo "$PLAYER: \$$PLAYER_TOURNAMENT_WINNINGS ($PLAYER_TOURNAMENT_CASHES)"

  ROW_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 winnings-column1\">$PLAYER</td>
                        <td class=\"cell100 winnings-column2\"><span class="currency">$PLAYER_TOURNAMENT_WINNINGS</span> | <span class="currency">$PLAYER_PROFIT</span></td>
                      </tr>
"
  TOURNAMENT_TABLE_BODY="$TOURNAMENT_TABLE_BODY $ROW_TEMPLATE"
done

FINAL=$(awk -v r="$CASH_TABLE_BODY" '{gsub(/_CASH_TABLE_BODY_/,r)}1' templates/winnings.tmpl)
FINAL="${FINAL/_GENERATED_ON_/$DATE}"
FINAL="${FINAL//_POKER_SITE_NAME_/$POKER_SITE_NAME}"
FINAL="${FINAL/_TOURNAMENT_TABLE_BODY_/$TOURNAMENT_TABLE_BODY}"
echo "$FINAL" > web/results-winnings.html

echo ""
