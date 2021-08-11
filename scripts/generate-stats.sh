#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common.sh"

DATE=`date "+Generated on %B %d, %Y"`

# copy the files we care about to temp directories for easier grep'ing later
TOURNMANENT_TEMP_DIR=`mktemp -d`
CASH_TEMP_DIR=`mktemp -d`
echo "=========   PREPARING   ========="
echo "Copying files from $PM_DATA_HAND_HISTORY_DIR to temp directories..."
echo "  Cash       -> $TOURNMANENT_TEMP_DIR"
echo "  Tournament -> $TOURNMANENT_TEMP_DIR"
echo 

grep -l "Starting tournament" $PM_DATA_HAND_HISTORY_DIR/* | xargs -d "\n" cp -t $TOURNMANENT_TEMP_DIR
grep -L "Starting tournament" $PM_DATA_HAND_HISTORY_DIR/* | xargs -d "\n" cp -t $CASH_TEMP_DIR

GREP_FILE_PATTERN_TOURNAMENT="$TOURNMANENT_TEMP_DIR/*"
GREP_FILE_PATTERN_CASH="$CASH_TEMP_DIR/*"

GREP_FILE_PATTERN_ALL="$PM_DATA_HAND_HISTORY_DIR/*"
GREP_FILE_PATTERN_TOURNAMENT_RESULTS="$PM_DATA_TOURNEY_DIR/*"

HANDS=( "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2" )

echo "=========   SITE STATISTICS   ========="
echo "Processing site-wide stats ..."
TOTAL_PLAYER_HANDS=`egrep -e 'Seat.*\[\w\w \w\w\]' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TABLE_HANDS=`egrep -e 'Hand #' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
FLOPS_SEEN=`egrep -e '\*\* Flop \*\*' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
FLOPS_SEEN_PCT=$(bc <<< "scale=4; x = $FLOPS_SEEN / $TABLE_HANDS * 100; scale = 2; x / 1")
FLOPS_WITH_SAME_SUIT=`egrep -e '\*\* Flop \*\* (?:\[\ws \ws \ws\]|\[\wh \wh \wh\]|\[\wc \wc \wc\]|\[\wd \wd \wd\])' $GREP_FILE_PATTERN_ALL | wc -l`
FLOPS_WITH_SAME_SUIT_PCT=$(bc <<< "scale=4; x = $FLOPS_WITH_SAME_SUIT / $FLOPS_SEEN * 100; scale = 2; x / 1")

AK_HANDS_WON=`egrep "^.* \(\+.*\) (\[A\w K\w\]|\[K\w A\w\])" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
AK_HANDS_LOST=`egrep "^.* \(\-.*\) (\[A\w K\w\]|\[K\w A\w\])" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
AK_HANDS_TOTAL=$(($AK_HANDS_WON+$AK_HANDS_LOST))
AK_HANDS_WON_PCT=$(bc <<< "scale=2; x = $AK_HANDS_WON/$AK_HANDS_TOTAL * 100; scale = 0; x / 1")

ROYAL_FLUSHES=`egrep -e '.*shows.*Royal' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
ROYAL_FLUSH_PCT=$(bc <<< "scale=6; x = $ROYAL_FLUSHES / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
POCKET_AA=`egrep -e 'Seat.*\[A\w A\w\]' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
POCKET_AA_PCT=$(bc <<< "scale=4; x = $POCKET_AA / $TOTAL_PLAYER_HANDS * 100; scale = 2; x / 1")
STRAIGHT_FLUSH=`egrep -e '.*shows.*Straight Flush' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT_FLUSH_PCT=$(bc <<< "scale=6; x = $STRAIGHT_FLUSH / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
QUADS=`egrep -e '.*shows.*Four of a Kind' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
QUADS_PCT=$(bc <<< "scale=6; x = $QUADS / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
FULL_HOUSE=`egrep -e '.*shows.*Full House' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
FULL_HOUSE_PCT=$(bc <<< "scale=6; x = $FULL_HOUSE / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
FLUSH=`egrep -e '.*shows.*Flush' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
FLUSH_PCT=$(bc <<< "scale=6; x = $FLUSH / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
STRAIGHT=`egrep -e '.*shows.*Straight' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT_PCT=$(bc <<< "scale=6; x = $STRAIGHT / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
THREE_KIND=`egrep -e '.*shows.*Three of a Kind' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
THREE_KIND_PCT=$(bc <<< "scale=6; x = $THREE_KIND / $TOTAL_PLAYER_HANDS * 100; scale = 4; x / 1")
TWO_PAIR=`egrep -e '.*shows.*Two Pair' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TWO_PAIR_PCT=$(bc <<< "scale=4; x = $TWO_PAIR / $TOTAL_PLAYER_HANDS * 100; scale = 2; x / 1")
PAIR=`egrep -e '.*shows.*a Pair' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
PAIR_PCT=$(bc <<< "scale=4; x = $PAIR / $TOTAL_PLAYER_HANDS * 100; scale = 2; x / 1")
HIGH_CARD=`egrep -e '.*shows.*High Card' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
HIGH_CARD_PCT=$(bc <<< "scale=4; x = $HIGH_CARD / $TOTAL_PLAYER_HANDS * 100; scale = 2; x / 1")

printf "Flops Seen: %'d (%.2f%%)  Dealt: %'d  Suited Flops: %'d (%.2f%%) AA: %'d (%.2f%%)\n" \
  $FLOPS_SEEN $FLOPS_SEEN_PCT $TABLE_HANDS $FLOPS_WITH_SAME_SUIT $FLOPS_WITH_SAME_SUIT_PCT $POCKET_AA $POCKET_AA_PCT

printf "Royal Flushes: %'d (%.4f%%) Straight Flushes: %'d (%.4f%%) Quads: %'d (%.2f%%) FH: %'d (%.2f%%) Flush: %'d (%.2f%%) Straight: %'d (%.2f%%) 3-Kind: %'d (%.2f%%)\n" \
  $ROYAL_FLUSHES $ROYAL_FLUSH_PCT $STRAIGHT_FLUSH $STRAIGHT_FLUSH_PCT $QUADS $QUADS_PCT $FULL_HOUSE $FULL_HOUSE_PCT $FLUSH $FLUSH_PCT $STRAIGHT $STRAIGHT_PCT $THREE_KIND $THREE_KIND_PCT

# format the big numbers
FULL_HOUSE=$(printf "%'d" $FULL_HOUSE)
FLUSH=$(printf "%'d" $FLUSH)
STRAIGHT=$(printf "%'d" $STRAIGHT)
THREE_KIND=$(printf "%'d" $THREE_KIND)
TWO_PAIR=$(printf "%'d" $TWO_PAIR)
PAIR=$(printf "%'d" $PAIR)
HIGH_CARD=$(printf "%'d" $HIGH_CARD)
AK_HANDS_WON=$(printf "%'d" $AK_HANDS_WON)

TABLE_BODY=""
PLAYER_POCKET_PAIRS_BODY=""
PLAYERS_SUMMARY="\n========= TOURNAMENT WINNINGS =========\n"

echo -e "\n=========  PLAYER STATISTICS  ========="
for PLAYER in "${PLAYERS[@]}"
do
  NOW="$(date +'%I:%M:%S')"
  echo "[$NOW] Processing all hands for $PLAYER ..."
  
  PPP_ROW_TEMPLATE="<tr class=\"row100 body\"><td class=\"playerpocketpair-cell\">$PLAYER</td>"

  PLAYER_FOLDED_HANDS_TOURNAMENT=`egrep -e "$PLAYER folds" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_SHOWN_HANDS_TOURNAMENT=`egrep -e "$PLAYER shows" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_REFUNDED_HANDS_TOURNAMENT=`egrep -e "$PLAYER refunded" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_WON_HANDS_TOURNAMENT=`egrep -e "$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT=`egrep -he "$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_TOURNAMENT | egrep -o "\(.*\)" | egrep -oe '\([0-9]{2,}\.?.*\)' | tr -d '()' | awk '{s+=$1} END {print s}'`
  PLAYER_ALL_INS_TOURNAMENT=`egrep -e "$PLAYER .*(All-in)" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_HANDS_PLAYED_TOURNAMENT=`python scripts/hands-played.py --player $PLAYER --pattern "$GREP_FILE_PATTERN_TOURNAMENT"`
  PLAYER_NUMBER_OF_TOURNAMENTS=`egrep -e "=$PLAYER " $GREP_FILE_PATTERN_TOURNAMENT_RESULTS | wc -l | sed -e 's/^[[:space:]]*//'`

  # calculate tournament winnings
  PLAYER_TOURNAMENT_WINNINGS=$(calculatePlayerTournamentWinnings "$PLAYER")
  PLAYER_TOURNAMENT_CASHES=$(calculatePlayerNumberOfCashes $PLAYER)
  if [[ -z $PLAYER_TOURNAMENT_WINNINGS ]]; then
    PLAYER_TOURNAMENT_WINNINGS=0
    PLAYER_TOURNAMENT_CASHES=0
  fi

  PLAYER_FOLDED_HANDS_CASH=`egrep -e "$PLAYER folds" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_SHOWN_HANDS_CASH=`egrep -e "$PLAYER shows" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_REFUNDED_HANDS_CASH=`egrep -e "$PLAYER refunded" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_WON_HANDS_CASH=`egrep -e "$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_TOTAL_WON_POT_SIZE_CASH=`egrep -he "$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | egrep -o "\(.*\)" | egrep -oe '\([0-9]{1,}\.?.*\)' | tr -d '()' | awk '{s+=$1} END {print s}'`
  PLAYER_ALL_INS_CASH=`egrep -e "$PLAYER .*(All-in)" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_HANDS_PLAYED_CASH=`python scripts/hands-played.py --player $PLAYER --pattern "$GREP_FILE_PATTERN_CASH"`
  PLAYER_BIGGEST_CASH_HAND=`egrep -ho "$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | egrep -o "\(.*\)" | egrep -o "[0-9,.]+" | sort -n | tail -n 1`

  TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT=$(($PLAYER_FOLDED_HANDS_TOURNAMENT + $PLAYER_SHOWN_HANDS_TOURNAMENT + $PLAYER_REFUNDED_HANDS_TOURNAMENT))
  TOTAL_PLAYER_HANDS_DEALT_CASH=$(($PLAYER_FOLDED_HANDS_CASH + $PLAYER_SHOWN_HANDS_CASH + $PLAYER_REFUNDED_HANDS_CASH))
  TOTAL_PLAYER_HANDS_DEALT=$(($TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT + $TOTAL_PLAYER_HANDS_DEALT_CASH))

  HANDS_WON_CASH_PCT=0
  HANDS_WON_TOURNAMENT_PCT=0
  HANDS_PLAYED_CASH_PCT=0
  HANDS_PLAYED_TOURNAMENT_PCT=0
  PLAYER_AVG_WON_POT_SIZE_CASH=0
  PLAYER_ALL_INS_CASH_PCT=0
  PLAYER_ALL_INS_CASH_RATE=0
  PLAYER_ALL_INS_TOURNAMENT_PCT=0
  PLAYER_ALL_INS_TOURNAMENT_RATE=0
  if [[ "PLAYER_HANDS_PLAYED_CASH" -ne 0 ]]; then
    HANDS_WON_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_WON_HANDS_CASH / $PLAYER_HANDS_PLAYED_CASH * 100; scale = 2; x / 1")
    HANDS_PLAYED_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_HANDS_PLAYED_CASH / $TOTAL_PLAYER_HANDS_DEALT_CASH * 100; scale = 2; x / 1")
    if [[ "PLAYER_WON_HANDS_CASH" -ne 0 ]]; then
      PLAYER_AVG_WON_POT_SIZE_CASH=$(bc <<< "scale=4; x = $PLAYER_TOTAL_WON_POT_SIZE_CASH / $PLAYER_WON_HANDS_CASH; scale = 2; x / 1")
    fi

    PLAYER_ALL_INS_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_CASH / $TOTAL_PLAYER_HANDS_DEALT_CASH * 100; scale = 2; x / 1")
    PLAYER_ALL_INS_CASH_RATE=$(bc <<< "scale=4; x = $TOTAL_PLAYER_HANDS_DEALT_CASH / $PLAYER_ALL_INS_CASH; scale = 0; x / 1")
  fi

  if [ "$PLAYER_HANDS_PLAYED_TOURNAMENT" -ne "0" ]; then
    HANDS_WON_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_WON_HANDS_TOURNAMENT / $PLAYER_HANDS_PLAYED_TOURNAMENT * 100; scale = 2; x / 1")
    HANDS_PLAYED_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_HANDS_PLAYED_TOURNAMENT / $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT * 100; scale = 2; x / 1")

    PLAYER_ALL_INS_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_TOURNAMENT / $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT * 100; scale = 2; x / 1")
    PLAYER_ALL_INS_TOURNAMENT_RATE=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_TOURNAMENT / $PLAYER_NUMBER_OF_TOURNAMENTS; scale = 0; x / 1")
  fi

  if [[ "TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT" -eq 0 ]] && [[ "TOTAL_PLAYER_HANDS_DEALT_CASH" -eq 0 ]]; then
    continue
  fi

  # calculate player cash total
  PLAYER_CASH_TOTAL=$(calculatePlayerCashTotal "$PLAYER")

  # calculate odds
  PLAYER_WINNING_ODDS_PCT=0
  if [ "$PLAYER_NUMBER_OF_TOURNAMENTS" -ne "0" ]; then
    PLAYER_WINNING_ODDS_PCT=$(bc <<< "scale=4; x = $PLAYER_TOURNAMENT_CASHES / $PLAYER_NUMBER_OF_TOURNAMENTS * 100; scale = 2; x / 1")
  fi

  # format the odds
  PLAYER_WINNING_ODDS_PCT=$(printf "%.2f" $PLAYER_WINNING_ODDS_PCT)

  # format the big numbers
  PLAYER_HANDS_PLAYED_CASH=$(printf "%'d" $PLAYER_HANDS_PLAYED_CASH)
  PLAYER_HANDS_PLAYED_TOURNAMENT=$(printf "%'d" $PLAYER_HANDS_PLAYED_TOURNAMENT)
  PLAYER_WON_HANDS_TOURNAMENT=$(printf "%'d" $PLAYER_WON_HANDS_TOURNAMENT)
  PLAYER_WON_HANDS_CASH=$(printf "%'d" $PLAYER_WON_HANDS_CASH)
  PLAYER_ALL_INS_TOURNAMENT=$(printf "%'d (%.2f%%)<br>%'d / Tournament" $PLAYER_ALL_INS_TOURNAMENT $PLAYER_ALL_INS_TOURNAMENT_PCT $PLAYER_ALL_INS_TOURNAMENT_RATE)
  PLAYER_ALL_INS_CASH=$(printf "%'d (%.2f%%)<br>1-in-%'d" $PLAYER_ALL_INS_CASH $PLAYER_ALL_INS_CASH_PCT $PLAYER_ALL_INS_CASH_RATE)
  TOTAL_PLAYER_HANDS_DEALT_CASH_FORMATTED=$(printf "%'d" $TOTAL_PLAYER_HANDS_DEALT_CASH)
  TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT=$(printf "%'d" $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT)
  PLAYER_BIGGEST_CASH_HAND=$(printf "%'.2Lf" $PLAYER_BIGGEST_CASH_HAND)

  ROW_TEMPLATE_TOURNAMENT="
                      <tr class=\"row100 body\">
                        <td class=\"playerstats-cell\">$PLAYER</td>
                        <td class=\"playerstats-cell\">$PLAYER_WON_HANDS_TOURNAMENT<br/>($HANDS_WON_TOURNAMENT_PCT%)</td>
                        <td class=\"playerstats-cell\">$PLAYER_HANDS_PLAYED_TOURNAMENT<br/>($HANDS_PLAYED_TOURNAMENT_PCT%)</td>
                        <td class=\"playerstats-cell\">$TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT</td>
                        <td class=\"playerstats-cell\">$PLAYER_ALL_INS_TOURNAMENT</td>
                        <td class=\"playerstats-cell\">$PLAYER_NUMBER_OF_TOURNAMENTS</td>
                        <td class=\"playerstats-cell\"><span class=\"currency\">$PLAYER_TOURNAMENT_WINNINGS</span></td>
                        <td class=\"playerstats-cell\">$PLAYER_WINNING_ODDS_PCT%</td>
                      </tr>
"

  ROW_TEMPLATE_CASH="
                      <tr class=\"row100 body\">
                        <td class=\"playerstats-cell\">$PLAYER</td>
                        <td class=\"playerstats-cell\">$PLAYER_WON_HANDS_CASH<br/>($HANDS_WON_CASH_PCT%)</td>
                        <td class=\"playerstats-cell\">$PLAYER_HANDS_PLAYED_CASH<br/>($HANDS_PLAYED_CASH_PCT%)</td>
                        <td class=\"playerstats-cell\">$TOTAL_PLAYER_HANDS_DEALT_CASH_FORMATTED</td>
                        <td class=\"playerstats-cell\">$PLAYER_ALL_INS_CASH</td>
                        <td class=\"playerstats-cell\"><span class=\"posMoney\">$PLAYER_AVG_WON_POT_SIZE_CASH</span></td>
                        <td class=\"playerstats-cell\"><span class=\"posMoney\">$PLAYER_BIGGEST_CASH_HAND</span></td>
                        <td class=\"playerstats-cell\"><span class=\"currency\">$PLAYER_CASH_TOTAL</span></td>
                      </tr>
"

  # buld up the body
  TABLE_BODY_TOURNAMENT="$TABLE_BODY_TOURNAMENT $ROW_TEMPLATE_TOURNAMENT"

  if [[ "TOTAL_PLAYER_HANDS_DEALT_CASH" -ne 0 ]]; then
    TABLE_BODY_CASH="$TABLE_BODY_CASH $ROW_TEMPLATE_CASH"
  fi

  PLAYERS_SUMMARY="$PLAYERS_SUMMARY$PLAYER: \$$PLAYER_TOURNAMENT_WINNINGS ($PLAYER_WINNING_ODDS_PCT%)\n"

  # process per-player pocket pairs
  for HAND in "${HANDS[@]}"
  do
    NUM_PLAYER_POCKET_PAIRS=`egrep -oh "$PLAYER \(.*\) \[$HAND\w $HAND\w\]" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
    PLAYER_POCKET_PAIR_PCT=0
    if [[ "TOTAL_PLAYER_HANDS_DEALT" -ne 0 ]]; then
      PLAYER_POCKET_PAIR_PCT=$(bc <<< "scale=4; x = $NUM_PLAYER_POCKET_PAIRS / $TOTAL_PLAYER_HANDS_DEALT * 100; scale = 2; x / 1")
    fi

    PLAYER_POCKET_PAIR_PCT=$(printf "%.2f" $PLAYER_POCKET_PAIR_PCT)

    # format the big numbers
    NUM_PLAYER_POCKET_PAIRS=$(printf "%'d" $NUM_PLAYER_POCKET_PAIRS)

    # append another <td>
    PPP_TD="<td class=\"playerstats-cell\">$NUM_PLAYER_POCKET_PAIRS<br/>($PLAYER_POCKET_PAIR_PCT%)</td>"
    PPP_ROW_TEMPLATE="$PPP_ROW_TEMPLATE $PPP_TD"
  done

  # append <tr>
  PLAYER_POCKET_PAIRS_BODY="$PLAYER_POCKET_PAIRS_BODY $PPP_ROW_TEMPLATE</tr>"
done

echo -e "$PLAYERS_SUMMARY"

STATS_HTML_CONTENT=$(awk -v r="$TABLE_BODY_TOURNAMENT" '{gsub(/_PLAYER_TOURNAMENT_STATS_BODY_/,r)}1' templates/stats.tmpl)
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_PLAYER_CASH_STATS_BODY_/$TABLE_BODY_CASH}"

# create site-wide stats
# format the big numbers
TOTAL_PLAYER_HANDS_FORMATTED=$(printf "%'d" $TOTAL_PLAYER_HANDS)
TABLE_HANDS=$(printf "%'d" $TABLE_HANDS)
FLOPS_SEEN=$(printf "%'d" $FLOPS_SEEN)
FLOPS_WITH_SAME_SUIT=$(printf "%'d" $FLOPS_WITH_SAME_SUIT)

# format the little numbers
ROYAL_FLUSH_PCT=$(printf "%.4f" $ROYAL_FLUSH_PCT)
STRAIGHT_FLUSH_PCT=$(printf "%.4f" $STRAIGHT_FLUSH_PCT)
QUADS_PCT=$(printf "%.4f" $QUADS_PCT)
FULL_HOUSE_PCT=$(printf "%.3f" $FULL_HOUSE_PCT)
FLUSH_PCT=$(printf "%.3f" $FLUSH_PCT)
STRAIGHT_PCT=$(printf "%.3f" $STRAIGHT_PCT)
THREE_KIND_PCT=$(printf "%.3f" $THREE_KIND_PCT)
POCKET_AA_PCT=$(printf "%.2f" $POCKET_AA_PCT)

SITE_STATS_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Total Hands Dealt</td>
                        <td class=\"cell100 stats-column2\">$TOTAL_PLAYER_HANDS_FORMATTED</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Table Hands</td>
                        <td class=\"cell100 stats-column2\">$TABLE_HANDS</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Flops Seen</td>
                        <td class=\"cell100 stats-column2\">$FLOPS_SEEN ($FLOPS_SEEN_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Suited Flops</td>
                        <td class=\"cell100 stats-column2\">$FLOPS_WITH_SAME_SUIT ($FLOPS_WITH_SAME_SUIT_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Pocket AA</td>
                        <td class=\"cell100 stats-column2\">$POCKET_AA ($POCKET_AA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Ace King Wins</td>
                        <td class=\"cell100 stats-column2\">$AK_HANDS_WON ($AK_HANDS_WON_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Royal Flushes</td>
                        <td class=\"cell100 stats-column2\">$ROYAL_FLUSHES ($ROYAL_FLUSH_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Straight Flushes</td>
                        <td class=\"cell100 stats-column2\">$STRAIGHT_FLUSH ($STRAIGHT_FLUSH_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">4-of-a-Kind</td>
                        <td class=\"cell100 stats-column2\">$QUADS ($QUADS_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Full House</td>
                        <td class=\"cell100 stats-column2\">$FULL_HOUSE ($FULL_HOUSE_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Flush</td>
                        <td class=\"cell100 stats-column2\">$FLUSH ($FLUSH_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Straight</td>
                        <td class=\"cell100 stats-column2\">$STRAIGHT ($STRAIGHT_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">3-of-a-Kind</td>
                        <td class=\"cell100 stats-column2\">$THREE_KIND ($THREE_KIND_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Two Pair</td>
                        <td class=\"cell100 stats-column2\">$TWO_PAIR ($TWO_PAIR_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Pair</td>
                        <td class=\"cell100 stats-column2\">$PAIR ($PAIR_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">High Card</td>
                        <td class=\"cell100 stats-column2\">$HIGH_CARD ($HIGH_CARD_PCT%)</td>
                      </tr>
"

# find all pocket pair stats
echo "=========  SITE POCKET PAIRS  ========="
echo "[$(date +'%I:%M:%S')] Processing all site pocket pairs..."
SITE_POCKET_PAIRS_BODY=""
for HAND in "${HANDS[@]}"
do
  echo "[$(date +'%I:%M:%S')] Processing [$HAND $HAND]..."
  POCKET_PAIR=`egrep -e "Seat.*\[$HAND\w $HAND\w\]" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR / $TOTAL_PLAYER_HANDS * 100; scale = 2; x / 1")
  POCKET_PAIR_PCT=$(printf "%.2f" $POCKET_PAIR_PCT)
  POCKET_PAIR_ONE_IN=$(bc <<< "scale=4; x = $TOTAL_PLAYER_HANDS/$POCKET_PAIR; scale = 0; x / 1")

  POCKET_PAIR_HANDS_WON=`egrep "^.* \(\+.*\) (\[$HAND\w $HAND\w\])" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_WON_SHOWDOWN=`egrep "^.* \(\+.*\) (\[$HAND\w $HAND\w\]) Showdown" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_LOST=`egrep "^.* \(\-.*\) (\[$HAND\w $HAND\w\])" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_TOTAL=$(($POCKET_PAIR_HANDS_WON+$POCKET_PAIR_HANDS_LOST))
  POCKET_PAIR_HANDS_WON_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR_HANDS_WON/$POCKET_PAIR_HANDS_TOTAL * 100; scale = 2; x / 1")
  POCKET_PAIR_HANDS_WON_SHOWDOWN_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR_HANDS_WON_SHOWDOWN/$POCKET_PAIR_HANDS_TOTAL * 100; scale = 2; x / 1")

  # append another <td>
  POCKET_PAIR_TR="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-medium-column\">$HAND$HAND</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR ($POCKET_PAIR_PCT%) 1-in-$POCKET_PAIR_ONE_IN</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR_HANDS_WON ($POCKET_PAIR_HANDS_WON_PCT%)</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR_HANDS_WON_SHOWDOWN ($POCKET_PAIR_HANDS_WON_SHOWDOWN_PCT%)</td>
                      </tr>
  "
  SITE_POCKET_PAIRS_BODY="$SITE_POCKET_PAIRS_BODY $POCKET_PAIR_TR"
done

# update site-wide stats
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_SITE_STATS_BODY_/$SITE_STATS_TEMPLATE}"

# add player pocket pairs status
PLAYER_POCKET_PAIRS_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $PLAYER_POCKET_PAIRS_BODY`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_PLAYER_POCKET_PAIRS_BODY_/$PLAYER_POCKET_PAIRS_BODY}"

# add site pocket pairs
SITE_POCKET_PAIRS_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $SITE_POCKET_PAIRS_BODY`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_SITE_POCKET_PAIRS_BODY_/$SITE_POCKET_PAIRS_BODY}"

# add generation date
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_GENERATED_ON_/$DATE}"

# add poker site name
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_POKER_SITE_NAME_/$POKER_SITE_NAME}"

# print it to the file
echo "$STATS_HTML_CONTENT" > web/stats.html
