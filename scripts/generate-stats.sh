#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/players.sh"
. "$DIR/common.sh"

DATE=`date "+Generated on %B %d, %Y"`

HANDS=( "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2" )

FLOPS_SEEN_PCT=$(bc <<< "scale=4; x = $FLOPS_SEEN / $TABLE_HANDS * 100; scale = 2; x / 1")
FLOPS_WITH_SAME_SUIT_PCT=$(bc <<< "scale=4; x = $FLOPS_WITH_SAME_SUIT / $FLOPS_SEEN * 100; scale = 2; x / 1")
AK_HANDS_WON=$(($AK_HANDS_TOTAL-$AK_HANDS_LOST))
AK_HANDS_WON_PCT=$(bc <<< "scale=2; x = $AK_HANDS_WON/$AK_HANDS_TOTAL * 100; scale = 0; x / 1")
SEVENTWO_HANDS_WON=$(($SEVENTWO_HANDS_TOTAL-$SEVENTWO_HANDS_LOST))
SEVENTWO_HANDS_WON_PCT=$(bc <<< "scale=2; x = $SEVENTWO_HANDS_WON/$SEVENTWO_HANDS_TOTAL * 100; scale = 0; x / 1")

# Hold'em hand ranking stats
if [[ $TOTAL_PLAYER_HANDS_HOLDEM -gt 0 ]]; then
  ROYAL_FLUSH_PCT=$(bc <<< "scale=6; x = $ROYAL_FLUSHES / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  POCKET_AA_PCT=$(bc <<< "scale=4; x = $POCKET_AA / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 2; x / 1")
  STRAIGHT_FLUSH_PCT=$(bc <<< "scale=6; x = $STRAIGHT_FLUSH / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  QUADS_PCT=$(bc <<< "scale=6; x = $QUADS / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  FULL_HOUSE_PCT=$(bc <<< "scale=6; x = $FULL_HOUSE / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  FLUSH_PCT=$(bc <<< "scale=6; x = $FLUSH / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  STRAIGHT_PCT=$(bc <<< "scale=6; x = $STRAIGHT / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  THREE_KIND_PCT=$(bc <<< "scale=6; x = $THREE_KIND / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 4; x / 1")
  TWO_PAIR_PCT=$(bc <<< "scale=4; x = $TWO_PAIR / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 2; x / 1")
  PAIR_PCT=$(bc <<< "scale=4; x = $PAIR / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 2; x / 1")
  HIGH_CARD_PCT=$(bc <<< "scale=4; x = $HIGH_CARD / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 2; x / 1")
fi

# omaha hand ranking stats
if [[ $TOTAL_PLAYER_HANDS_OMAHA -gt 0 ]]; then
  ROYAL_FLUSH_OMAHA_PCT=$(bc <<< "scale=6; x = $ROYAL_OMAHA_FLUSHES / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  STRAIGHT_FLUSH_OMAHA_PCT=$(bc <<< "scale=6; x = $STRAIGHT_OMAHA_FLUSH / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  QUADS_OMAHA_PCT=$(bc <<< "scale=6; x = $QUADS_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  FULL_HOUSE_OMAHA_PCT=$(bc <<< "scale=6; x = $FULL_HOUSE_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  FLUSH_OMAHA_PCT=$(bc <<< "scale=6; x = $FLUSH_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  STRAIGHT_OMAHA_PCT=$(bc <<< "scale=6; x = $STRAIGHT_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  THREE_KIND_OMAHA_PCT=$(bc <<< "scale=6; x = $THREE_KIND_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 4; x / 1")
  TWO_PAIR_OMAHA_PCT=$(bc <<< "scale=4; x = $TWO_PAIR_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 2; x / 1")
  PAIR_OMAHA_PCT=$(bc <<< "scale=4; x = $PAIR_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 2; x / 1")
  HIGH_OMAHA_CARD_PCT=$(bc <<< "scale=4; x = $HIGH_CARD_OMAHA / $TOTAL_PLAYER_HANDS_OMAHA * 100; scale = 2; x / 1")
fi

# showdown stats
HAND_ENDS_PREFLOP_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_PREFLOP_TOURNAMENT / $TABLE_HANDS_TOURNAMENT * 100; scale = 2; x / 1")
HAND_ENDS_FLOP_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_FLOP_TOURNAMENT / $TABLE_HANDS_TOURNAMENT * 100; scale = 2; x / 1")
HAND_ENDS_TURN_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_TURN_TOURNAMENT / $TABLE_HANDS_TOURNAMENT * 100; scale = 2; x / 1")
HAND_ENDS_RIVER_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_RIVER_TOURNAMENT / $TABLE_HANDS_TOURNAMENT * 100; scale = 2; x / 1")
HAND_ENDS_SHOWDOWN_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_SHOWDOWN_TOURNAMENT / $TABLE_HANDS_TOURNAMENT * 100; scale = 2; x / 1")
HAND_ENDS_PREFLOP_CASH_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_PREFLOP_CASH / $TABLE_HANDS_CASH * 100; scale = 2; x / 1")
HAND_ENDS_FLOP_CASH_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_FLOP_CASH / $TABLE_HANDS_CASH * 100; scale = 2; x / 1")
HAND_ENDS_TURN_CASH_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_TURN_CASH / $TABLE_HANDS_CASH * 100; scale = 2; x / 1")
HAND_ENDS_RIVER_CASH_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_RIVER_CASH / $TABLE_HANDS_CASH * 100; scale = 2; x / 1")
HAND_ENDS_SHOWDOWN_CASH_PCT=$(bc <<< "scale=4; x = $HAND_ENDS_SHOWDOWN_CASH / $TABLE_HANDS_CASH * 100; scale = 2; x / 1")

echo "========= SITE STATISTICS ========="
printf " Player Hands Dealt: %'d \n Hold'em Hands Dealt: %'d \n Omaha Hands Dealt: %'d \n Table Hands: %'d \n Flops Seen: %'d (%.2f%%) \n Suited Flops: %'d (%.2f%%) \n AA: %'d (%.2f%%)\n" \
  $TOTAL_PLAYER_HANDS $TOTAL_PLAYER_HANDS_HOLDEM $TOTAL_PLAYER_HANDS_OMAHA $TABLE_HANDS $FLOPS_SEEN $FLOPS_SEEN_PCT $FLOPS_WITH_SAME_SUIT $FLOPS_WITH_SAME_SUIT_PCT $POCKET_AA $POCKET_AA_PCT

echo ""
echo " Texas Hold 'Em"
printf "  Royal Flushes: %'d (%.4f%%) \n  Straight Flushes: %'d (%.4f%%) \n  Quads: %'d (%.2f%%) \n  FH: %'d (%.2f%%) \n  Flush: %'d (%.2f%%) \n  Straight: %'d (%.2f%%) \n  3-Kind: %'d (%.2f%%)\n" \
  $ROYAL_FLUSHES $ROYAL_FLUSH_PCT $STRAIGHT_FLUSH $STRAIGHT_FLUSH_PCT $QUADS $QUADS_PCT $FULL_HOUSE $FULL_HOUSE_PCT $FLUSH $FLUSH_PCT $STRAIGHT $STRAIGHT_PCT $THREE_KIND $THREE_KIND_PCT

echo ""
echo " Omaha"
printf "  Royal Flushes: %'d (%.4f%%) \n  Straight Flushes: %'d (%.4f%%) \n  Quads: %'d (%.2f%%) \n  FH: %'d (%.2f%%) \n  Flush: %'d (%.2f%%) \n  Straight: %'d (%.2f%%) \n  3-Kind: %'d (%.2f%%)\n" \
  $ROYAL_FLUSHES_OMAHA $ROYAL_FLUSH_OMAHA_PCT $STRAIGHT_FLUSH_OMAHA $STRAIGHT_FLUSH_OMAHA_PCT $QUADS_OMAHA $QUADS_OMAHA_PCT $FULL_HOUSE_OMAHA $FULL_HOUSE_OMAHA_PCT $FLUSH_OMAHA $FLUSH_OMAHA_PCT $STRAIGHT_OMAHA $STRAIGHT_OMAHA_PCT $THREE_KIND_OMAHA $THREE_KIND_OMAHA_PCT

# format the big numbers
FULL_HOUSE=$(printf "%'d" $FULL_HOUSE)
FLUSH=$(printf "%'d" $FLUSH)
STRAIGHT=$(printf "%'d" $STRAIGHT)
THREE_KIND=$(printf "%'d" $THREE_KIND)
TWO_PAIR=$(printf "%'d" $TWO_PAIR)
PAIR=$(printf "%'d" $PAIR)
HIGH_CARD=$(printf "%'d" $HIGH_CARD)
AK_HANDS_WON=$(printf "%'d" $AK_HANDS_WON)
SEVENTWO_HANDS_WON=$(printf "%'d" $SEVENTWO_HANDS_WON)

TABLE_BODY=""
PLAYER_POCKET_PAIRS_BODY=""
PLAYERS_SUMMARY="========= TOURNAMENT WINNINGS =========\n"

echo ""
echo "=========  PLAYER STATISTICS  ========="
for PLAYER in "${PLAYERS[@]}"
do
  NOW="$(date +'%I:%M:%S')"
  echo "[$NOW] → Rendering all stats for $PLAYER ..."
  
  # read all player stats from the DB
  # if this player has no cards, don't do anything
  PLAYER_TOTAL_HANDS_DEALT=$(getPlayerStatFromDB "$PLAYER" "total_hands_dealt")
  if [[ $PLAYER_TOTAL_HANDS_DEALT == 0 ]]; then
    continue
  fi

  # player tournament stats
  PLAYER_FOLDED_HANDS_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "folded_hands_tournament")
  PLAYER_SHOWN_HANDS_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "shown_hands_tournament")
  PLAYER_REFUNDED_HANDS_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "refunded_hands_tournament")
  PLAYER_WON_HANDS_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "won_hands_tournament")
  PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "total_won_pot_size_tournament")
  PLAYER_ALL_INS_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "all_ins_tournament")
  PLAYER_HANDS_PLAYED_TOURNAMENT=$(getPlayerStatFromDB "$PLAYER" "hands_played_tournament")
  PLAYER_NUMBER_OF_TOURNAMENTS=$(getPlayerStatFromDB "$PLAYER" "tournaments_entered")

  # player cash stats
  PLAYER_FOLDED_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "folded_hands_cash")
  PLAYER_SHOWN_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "shown_hands_cash")
  PLAYER_REFUNDED_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "refunded_hands_cash")
  PLAYER_WON_HANDS_CASH=$(getPlayerStatFromDB "$PLAYER" "won_hands_cash")
  PLAYER_TOTAL_WON_POT_SIZE_CASH=$(getPlayerStatFromDB "$PLAYER" "total_won_pot_size_cash")
  PLAYER_ALL_INS_CASH=$(getPlayerStatFromDB "$PLAYER" "all_ins_cash")
  PLAYER_HANDS_PLAYED_CASH=$(getPlayerStatFromDB "$PLAYER" "hands_played_cash")  
  PLAYER_BIGGEST_CASH_HAND=$(getPlayerStatFromDB "$PLAYER" "largest_pot_won_cash")

  PPP_ROW_TEMPLATE="<tr class=\"row100 body\"><td class=\"playerpocketpair-cell\">$PLAYER</td>"

  # calculate tournament winnings
  PLAYER_TOURNAMENT_WINNINGS=$(getPlayerStatFromDB "$PLAYER" "tournament_gross_winnings")
  OFFSET=$(getPlayerStatFromDB "$PLAYER" "offset_tournament_winnings")
  PLAYER_TOURNAMENT_WINNINGS=`bc <<< "$OFFSET + $PLAYER_TOURNAMENT_WINNINGS"`  

  # get number of tournament cashes
  PLAYER_TOURNAMENT_CASHES=$(getPlayerStatFromDB "$PLAYER" "tournament_cashes")
  OFFSET=$(getPlayerStatFromDB "$PLAYER" "offset_tournament_num_cashes")
  PLAYER_TOURNAMENT_CASHES=`bc <<< "$OFFSET + $PLAYER_TOURNAMENT_CASHES"`

  if [[ -z $PLAYER_TOURNAMENT_WINNINGS ]]; then
    PLAYER_TOURNAMENT_WINNINGS=0
    PLAYER_TOURNAMENT_CASHES=0
  fi

  # debug
  # echo "$PLAYER (T): folded: $PLAYER_FOLDED_HANDS_TOURNAMENT shown: $PLAYER_SHOWN_HANDS_TOURNAMENT refund: $PLAYER_REFUNDED_HANDS_TOURNAMENT"
  # echo "$PLAYER (C): folded: $PLAYER_FOLDED_HANDS_CASH shown: $PLAYER_SHOWN_HANDS_CASH refund: $PLAYER_REFUNDED_HANDS_CASH"

  TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT=$(($PLAYER_FOLDED_HANDS_TOURNAMENT + $PLAYER_SHOWN_HANDS_TOURNAMENT + $PLAYER_REFUNDED_HANDS_TOURNAMENT))
  TOTAL_PLAYER_HANDS_DEALT_CASH=$(($PLAYER_FOLDED_HANDS_CASH + $PLAYER_SHOWN_HANDS_CASH + $PLAYER_REFUNDED_HANDS_CASH))
  TOTAL_PLAYER_HANDS_DEALT=$(getPlayerStatFromDB "$PLAYER" "total_hands_dealt")

  HANDS_WON_CASH_PCT=0
  HANDS_WON_TOURNAMENT_PCT=0
  HANDS_PLAYED_CASH_PCT=0
  HANDS_PLAYED_TOURNAMENT_PCT=0
  PLAYER_AVG_WON_POT_SIZE_CASH=0
  PLAYER_ALL_INS_CASH_PCT=0
  PLAYER_ALL_INS_CASH_RATE=0
  PLAYER_ALL_INS_TOURNAMENT_PCT=0
  PLAYER_ALL_INS_TOURNAMENT_RATE=0
  if [[ $PLAYER_HANDS_PLAYED_CASH != 0 ]]; then
    HANDS_WON_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_WON_HANDS_CASH / $PLAYER_HANDS_PLAYED_CASH * 100; scale = 2; x / 1")
    HANDS_PLAYED_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_HANDS_PLAYED_CASH / $TOTAL_PLAYER_HANDS_DEALT_CASH * 100; scale = 2; x / 1")
    if [[ $PLAYER_WON_HANDS_CASH != 0 ]]; then
      PLAYER_AVG_WON_POT_SIZE_CASH=$(bc <<< "scale=4; x = $PLAYER_TOTAL_WON_POT_SIZE_CASH / $PLAYER_WON_HANDS_CASH; scale = 2; x / 1")
    fi

    PLAYER_ALL_INS_CASH_PCT=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_CASH / $TOTAL_PLAYER_HANDS_DEALT_CASH * 100; scale = 2; x / 1")
    PLAYER_ALL_INS_CASH_RATE=$(bc <<< "scale=4; x = $TOTAL_PLAYER_HANDS_DEALT_CASH / $PLAYER_ALL_INS_CASH; scale = 0; x / 1")
  fi

  if [[ $PLAYER_HANDS_PLAYED_TOURNAMENT != 0 ]]; then
    HANDS_WON_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_WON_HANDS_TOURNAMENT / $PLAYER_HANDS_PLAYED_TOURNAMENT * 100; scale = 2; x / 1")
    HANDS_PLAYED_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_HANDS_PLAYED_TOURNAMENT / $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT * 100; scale = 2; x / 1")

    PLAYER_ALL_INS_TOURNAMENT_PCT=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_TOURNAMENT / $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT * 100; scale = 2; x / 1")
    PLAYER_ALL_INS_TOURNAMENT_RATE=$(bc <<< "scale=4; x = $PLAYER_ALL_INS_TOURNAMENT / $PLAYER_NUMBER_OF_TOURNAMENTS; scale = 0; x / 1")
  fi

  if [[ $TOTAL_PLAYER_HANDS_DEALT_TOURNAMENT == 0 ]] && [[ $TOTAL_PLAYER_HANDS_DEALT_CASH == 0 ]]; then
    continue
  fi

  # get player cash total from DB
  PLAYER_CASH_TOTAL=$(getPlayerCashTotalFromDB "$PLAYER")

  # calculate odds and finish position
  PLAYER_WINNING_ODDS_PCT=0
  PLAYER_AVG_FINISH_POSITION=0
  PLAYER_AVG_FINISH_TH="0th"
  if [[ $PLAYER_NUMBER_OF_TOURNAMENTS != 0 ]]; then
    PLAYER_WINNING_ODDS_PCT=$(bc <<< "scale=4; x = $PLAYER_TOURNAMENT_CASHES / $PLAYER_NUMBER_OF_TOURNAMENTS * 100; scale = 2; x / 1")
    PLAYER_AVG_FINISH_POSITION=$(calculatePlayerAverageTournmanentFinish "$PLAYER")
    PLAYER_AVG_FINISH_TH=`printf '%.0fth' "$PLAYER_AVG_FINISH_POSITION"`
  fi

  # format the odds
  PLAYER_WINNING_ODDS_PCT=$(printf "%.2f" $PLAYER_WINNING_ODDS_PCT)

  # format the big numbers
  PLAYER_HANDS_PLAYED_CASH=$(printf "%'d" $PLAYER_HANDS_PLAYED_CASH)
  PLAYER_HANDS_PLAYED_TOURNAMENT=$(printf "%'d" $PLAYER_HANDS_PLAYED_TOURNAMENT)
  PLAYER_WON_HANDS_TOURNAMENT=$(printf "%'d" $PLAYER_WON_HANDS_TOURNAMENT)
  PLAYER_WON_HANDS_CASH=$(printf "%'d" $PLAYER_WON_HANDS_CASH)
  PLAYER_ALL_INS_TOURNAMENT=$(printf "%'d (%.2f%%)<br>%'d / Tourn." $PLAYER_ALL_INS_TOURNAMENT $PLAYER_ALL_INS_TOURNAMENT_PCT $PLAYER_ALL_INS_TOURNAMENT_RATE)
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
                        <td class=\"playerstats-cell\">$PLAYER_AVG_FINISH_TH<br/>($PLAYER_AVG_FINISH_POSITION)</td>
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

  if [[ $TOTAL_PLAYER_HANDS_DEALT_CASH != 0 ]]; then
    TABLE_BODY_CASH="$TABLE_BODY_CASH $ROW_TEMPLATE_CASH"
  fi

  PLAYERS_SUMMARY="$PLAYERS_SUMMARY$PLAYER: \$$PLAYER_TOURNAMENT_WINNINGS ($PLAYER_WINNING_ODDS_PCT%)\n"

  # process per-player pocket pairs
  for CARD in "${HANDS[@]}"
  do
    NUM_PLAYER_POCKET_PAIRS=$(getPlayerHandFromDB "$PLAYER" "cards_$CARD$CARD")
    PLAYER_POCKET_PAIR_PCT=0
    if [[ $TOTAL_PLAYER_HANDS_DEALT != 0 ]]; then
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

echo ""
echo -e "$PLAYERS_SUMMARY"

STATS_HTML_CONTENT=$(awk -v r="$TABLE_BODY_TOURNAMENT" '{gsub(/_PLAYER_TOURNAMENT_STATS_BODY_/,r)}1' templates/stats.tmpl)
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_PLAYER_CASH_STATS_BODY_/$TABLE_BODY_CASH}"

# create site-wide stats
# format the big site-wide numbers
TOTAL_PLAYER_HANDS_FORMATTED=$(printf "%'d" $TOTAL_PLAYER_HANDS)
TOTAL_PLAYER_HANDS_HOLDEM_FORMATTED=$(printf "%'d" $TOTAL_PLAYER_HANDS_HOLDEM)
TOTAL_PLAYER_HANDS_OMAHA_FORMATTED=$(printf "%'d" $TOTAL_PLAYER_HANDS_OMAHA)
TABLE_HANDS=$(printf "%'d" $TABLE_HANDS)
FLOPS_SEEN=$(printf "%'d" $FLOPS_SEEN)
FLOPS_WITH_SAME_SUIT=$(printf "%'d" $FLOPS_WITH_SAME_SUIT)
POCKET_AA=$(printf "%'d" $POCKET_AA)

# format the little site-wide numbers
POCKET_AA_PCT=$(printf "%.2f" $POCKET_AA_PCT)

SITE_STATS_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Total Hands Dealt</td>
                        <td class=\"cell100 stats-column2\">$TOTAL_PLAYER_HANDS_FORMATTED</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Total Hands By Game</td>
                        <td class=\"cell100 stats-column2\">Hold 'Em: $TOTAL_PLAYER_HANDS_HOLDEM_FORMATTED
                          <br/>Omaha: $TOTAL_PLAYER_HANDS_OMAHA_FORMATTED
                        </td>
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
                        <td class=\"cell100 stats-column1\">
                          AK Wins<br/>
                          72 Wins<br/>
                        </td>
                        <td class=\"cell100 stats-column2\">
                          $AK_HANDS_WON ($AK_HANDS_WON_PCT%)<br/>
                          $SEVENTWO_HANDS_WON ($SEVENTWO_HANDS_WON_PCT%)<br/>
                        </td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Cash Hand Summary</td>
                        <td class=\"cell100 stats-column2\">
                          Pre-Flop: $HAND_ENDS_PREFLOP_CASH_PCT%<br>
                          Flop: $HAND_ENDS_FLOP_CASH_PCT%<br>
                          Turn: $HAND_ENDS_TURN_CASH_PCT%<br>
                          River: $HAND_ENDS_RIVER_CASH_PCT%<br>
                          Showdown: $HAND_ENDS_SHOWDOWN_CASH_PCT%<br>
                        </td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Tournament Hand Summary</td>
                        <td class=\"cell100 stats-column2\">
                          Pre-Flop: $HAND_ENDS_PREFLOP_TOURNAMENT_PCT%<br>
                          Flop: $HAND_ENDS_FLOP_TOURNAMENT_PCT%<br>
                          Turn: $HAND_ENDS_TURN_TOURNAMENT_PCT%<br>
                          River: $HAND_ENDS_RIVER_TOURNAMENT_PCT%<br>
                          Showdown: $HAND_ENDS_SHOWDOWN_TOURNAMENT_PCT%<br>
                        </td>
                      </tr>
"

# format the little holdem numbers
ROYAL_FLUSH_PCT=$(printf "%.4f" $ROYAL_FLUSH_PCT)
STRAIGHT_FLUSH_PCT=$(printf "%.4f" $STRAIGHT_FLUSH_PCT)
QUADS_PCT=$(printf "%.4f" $QUADS_PCT)
FULL_HOUSE_PCT=$(printf "%.3f" $FULL_HOUSE_PCT)
FLUSH_PCT=$(printf "%.3f" $FLUSH_PCT)
STRAIGHT_PCT=$(printf "%.3f" $STRAIGHT_PCT)
THREE_KIND_PCT=$(printf "%.3f" $THREE_KIND_PCT)

# holdem ranking template
TABLE_HAND_STATS_TEMPLATE="
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
# format the big omaha numbers
FULL_HOUSE_OMAHA=$(printf "%'d" $FULL_HOUSE_OMAHA)
FLUSH_OMAHA=$(printf "%'d" $FLUSH_OMAHA)
STRAIGHT_OMAHA=$(printf "%'d" $STRAIGHT_OMAHA)
THREE_KIND_OMAHA=$(printf "%'d" $THREE_KIND_OMAHA)
TWO_PAIR_OMAHA=$(printf "%'d" $TWO_PAIR_OMAHA)
PAIR_OMAHA=$(printf "%'d" $PAIR_OMAHA)
HIGH_CARD_OMAHA=$(printf "%'d" $HIGH_CARD_OMAHA)

# format the little omaha numbers
ROYAL_FLUSH_OMAHA_PCT=$(printf "%.4f" $ROYAL_FLUSH_OMAHA_PCT)
STRAIGHT_FLUSH_OMAHA_PCT=$(printf "%.4f" $STRAIGHT_FLUSH_OMAHA_PCT)
QUADS_OMAHA_PCT=$(printf "%.4f" $QUADS_OMAHA_PCT)
FULL_HOUSE_OMAHA_PCT=$(printf "%.3f" $FULL_HOUSE_OMAHA_PCT)
FLUSH_OMAHA_PCT=$(printf "%.3f" $FLUSH_OMAHA_PCT)
STRAIGHT_OMAHA_PCT=$(printf "%.3f" $STRAIGHT_OMAHA_PCT)
THREE_KIND_OMAHA_PCT=$(printf "%.3f" $THREE_KIND_OMAHA_PCT)

# omaha ranking template
TABLE_HAND_STATS_OMAHA_TEMPLATE="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Royal Flushes</td>
                        <td class=\"cell100 stats-column2\">$ROYAL_FLUSHES_OMAHA ($ROYAL_FLUSH_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Straight Flushes</td>
                        <td class=\"cell100 stats-column2\">$STRAIGHT_FLUSH_OMAHA ($STRAIGHT_FLUSH_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">4-of-a-Kind</td>
                        <td class=\"cell100 stats-column2\">$QUADS_OMAHA ($QUADS_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Full House</td>
                        <td class=\"cell100 stats-column2\">$FULL_HOUSE_OMAHA ($FULL_HOUSE_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Flush</td>
                        <td class=\"cell100 stats-column2\">$FLUSH_OMAHA ($FLUSH_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Straight</td>
                        <td class=\"cell100 stats-column2\">$STRAIGHT_OMAHA ($STRAIGHT_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">3-of-a-Kind</td>
                        <td class=\"cell100 stats-column2\">$THREE_KIND_OMAHA ($THREE_KIND_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Two Pair</td>
                        <td class=\"cell100 stats-column2\">$TWO_PAIR_OMAHA ($TWO_PAIR_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">Pair</td>
                        <td class=\"cell100 stats-column2\">$PAIR_OMAHA ($PAIR_OMAHA_PCT%)</td>
                      </tr>
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-column1\">High Card</td>
                        <td class=\"cell100 stats-column2\">$HIGH_CARD_OMAHA ($HIGH_CARD_OMAHA_PCT%)</td>
                      </tr>
"

# find all pocket pair stats
echo "[$(date +'%I:%M:%S')] → Rendering all site pocket pairs..."
SITE_POCKET_PAIRS_BODY=""
for CARD in "${HANDS[@]}"
do
  echo "[$(date +'%I:%M:%S')] Processing [$CARD $CARD]..."
  POCKET_PAIR=$(getPocketPairStatFromDB "$CARD$CARD" "total")
  POCKET_PAIR_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR / $TOTAL_PLAYER_HANDS_HOLDEM * 100; scale = 2; x / 1")
  POCKET_PAIR_PCT=$(printf "%.2f" $POCKET_PAIR_PCT)
  POCKET_PAIR_ONE_IN=$(bc <<< "scale=4; x = $TOTAL_PLAYER_HANDS/$POCKET_PAIR; scale = 0; x / 1")

  POCKET_PAIR_HANDS_WON=$(getPocketPairStatFromDB "$CARD$CARD" "total_won")
  POCKET_PAIR_HANDS_WON_SHOWDOWN=$(getPocketPairStatFromDB "$CARD$CARD" "total_won_at_showdown")
  POCKET_PAIR_HANDS_LOST=$(getPocketPairStatFromDB "$CARD$CARD" "lost")
  POCKET_PAIR_HANDS_TOTAL=$(($POCKET_PAIR_HANDS_WON+$POCKET_PAIR_HANDS_LOST))
  POCKET_PAIR_HANDS_WON_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR_HANDS_WON/$POCKET_PAIR_HANDS_TOTAL * 100; scale = 2; x / 1")
  POCKET_PAIR_HANDS_WON_SHOWDOWN_PCT=$(bc <<< "scale=4; x = $POCKET_PAIR_HANDS_WON_SHOWDOWN/$POCKET_PAIR_HANDS_TOTAL * 100; scale = 2; x / 1")

  # append another <td>
  POCKET_PAIR_TR="
                      <tr class=\"row100 body\">
                        <td class=\"cell100 stats-medium-column\">$CARD$CARD</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR ($POCKET_PAIR_PCT%) 1-in-$POCKET_PAIR_ONE_IN</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR_HANDS_WON ($POCKET_PAIR_HANDS_WON_PCT%)</td>
                        <td class=\"cell100 stats-medium-column\">$POCKET_PAIR_HANDS_WON_SHOWDOWN ($POCKET_PAIR_HANDS_WON_SHOWDOWN_PCT%)</td>
                      </tr>
  "
  SITE_POCKET_PAIRS_BODY="$SITE_POCKET_PAIRS_BODY $POCKET_PAIR_TR"
done
echo ""

# update site-wide stats
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_SITE_STATS_BODY_/$SITE_STATS_TEMPLATE}"

# add player pocket pairs status
PLAYER_POCKET_PAIRS_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $PLAYER_POCKET_PAIRS_BODY`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_PLAYER_POCKET_PAIRS_BODY_/$PLAYER_POCKET_PAIRS_BODY}"

# add holdem hand stats
TABLE_HAND_STATS_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $TABLE_HAND_STATS_TEMPLATE`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_TABLE_HAND_STATS_BODY_/$TABLE_HAND_STATS_BODY}"

# add omaha hand stats
TABLE_HAND_STATS_OMAHA_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $TABLE_HAND_STATS_OMAHA_TEMPLATE`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_TABLE_HAND_STATS_OMAHA_BODY_/$TABLE_HAND_STATS_OMAHA_BODY}"

# add site pocket pairs
SITE_POCKET_PAIRS_BODY=`tidy --show-body-only yes -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $SITE_POCKET_PAIRS_BODY`
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_SITE_POCKET_PAIRS_BODY_/$SITE_POCKET_PAIRS_BODY}"

# add generation date
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_GENERATED_ON_/$DATE}"

# add poker site name
STATS_HTML_CONTENT="${STATS_HTML_CONTENT//_POKER_SITE_NAME_/$POKER_SITE_NAME}"

# print it to the file
echo "$STATS_HTML_CONTENT" > web/stats.html
