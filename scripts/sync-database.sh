#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common-db.sh"

echo "========= SYNCHRONIZING ALL NEW DATA WITH THE DATABASE ========="

# sets up the database if it was not found
initializeDatabase

# ensure that there is a record for each player in every table before starting
ensurePlayersInTables

# copy only those files which have changed
copyFilesSinceLastSync

# set "ALL" files to the temp directory that holds files since last sync
GREP_FILE_PATTERN_ALL="$ALL_HANDS_SYNC_TEMP_DIR/*"

# the array of hands to create combinations for
HANDS=( "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2" )

# site stats
TOTAL_PLAYER_HANDS=`egrep -he 'Seat.*\[(\w| )+]' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TOTAL_PLAYER_HANDS=$(incrementSitePropertyInDB "total_hands" $TOTAL_PLAYER_HANDS)
TOTAL_PLAYER_HANDS_HOLDEM=`egrep -he 'Seat.*\[\w\w \w\w\]' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TOTAL_PLAYER_HANDS_HOLDEM=$(incrementSitePropertyInDB "total_hands_holdem" $TOTAL_PLAYER_HANDS_HOLDEM)
TOTAL_PLAYER_HANDS_OMAHA=`egrep -he 'Seat.*\[\w\w \w\w\ \w\w\ \w\w\]' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TOTAL_PLAYER_HANDS_OMAHA=$(incrementSitePropertyInDB "total_hands_omaha" $TOTAL_PLAYER_HANDS_OMAHA)
TABLE_HANDS=`egrep -he 'Hand #' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
TABLE_HANDS=$(incrementSitePropertyInDB "table_hands" $TABLE_HANDS)
TABLE_HANDS_CASH=`egrep -he 'Hand #' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
TABLE_HANDS_CASH=$(incrementSitePropertyInDB "table_hands_cash" $TABLE_HANDS_CASH)
TABLE_HANDS_TOURNAMENT=`egrep -he 'Hand #' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
TABLE_HANDS_TOURNAMENT=$(incrementSitePropertyInDB "table_hands_tournament" $TABLE_HANDS_TOURNAMENT)
FLOPS_SEEN=`egrep -he '\*\* Flop \*\*' $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
FLOPS_SEEN=$(incrementSitePropertyInDB "flops_seen" $FLOPS_SEEN)
FLOPS_WITH_SAME_SUIT=`egrep -he '\*\* Flop \*\* (?:\[\ws \ws \ws\]|\[\wh \wh \wh\]|\[\wc \wc \wc\]|\[\wd \wd \wd\])' $GREP_FILE_PATTERN_ALL | wc -l`
FLOPS_WITH_SAME_SUIT=$(incrementSitePropertyInDB "suited_flops" $FLOPS_WITH_SAME_SUIT)
POCKET_AA=`egrep -he 'Seat.*\[A\w A\w\]' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
POCKET_AA=$(incrementSitePropertyInDB "pocket_aa" $POCKET_AA)
AK_HANDS_TOTAL=`egrep -h "^.* \(.*\) (\[A\w K\w\]|\[K\w A\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
AK_HANDS_TOTAL=$(incrementSitePropertyInDB "ace_king_total" $AK_HANDS_TOTAL)
AK_HANDS_LOST=`egrep -h "^.* (\(\-.*\)|\(\+0\)) (\[A\w K\w\]|\[K\w A\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
AK_HANDS_LOST=$(incrementSitePropertyInDB "ace_king_lost" $AK_HANDS_LOST)
SEVENTWO_HANDS_TOTAL=`egrep -h "^.* \(.*\) (\[7\w 2\w\]|\[2\w 7\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
SEVENTWO_HANDS_TOTAL=$(incrementSitePropertyInDB "seven_two_total" $SEVENTWO_HANDS_TOTAL)
SEVENTWO_HANDS_LOST=`egrep -h "^.* (\(\-.*\)|\(\+0\)) (\[7\w 2\w\]|\[2\w 7\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
SEVENTWO_HANDS_LOST=$(incrementSitePropertyInDB "seven_two_lost" $SEVENTWO_HANDS_LOST)
HAND_ENDS_PREFLOP_TOURNAMENT=`egrep -he 'End: PreFlop' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_PREFLOP_TOURNAMENT=$(incrementSitePropertyInDB "hand_ends_preflop_tournament" $HAND_ENDS_PREFLOP_TOURNAMENT)
HAND_ENDS_FLOP_TOURNAMENT=`egrep -he 'End: Flop' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_FLOP_TOURNAMENT=$(incrementSitePropertyInDB "hand_ends_flop_tournament" $HAND_ENDS_FLOP_TOURNAMENT)
HAND_ENDS_TURN_TOURNAMENT=`egrep -he 'End: Turn' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_TURN_TOURNAMENT=$(incrementSitePropertyInDB "hand_ends_turn_tournament" $HAND_ENDS_TURN_TOURNAMENT)
HAND_ENDS_RIVER_TOURNAMENT=`egrep -he 'End: River' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_RIVER_TOURNAMENT=$(incrementSitePropertyInDB "hand_ends_river_tournament" $HAND_ENDS_RIVER_TOURNAMENT)
HAND_ENDS_SHOWDOWN_TOURNAMENT=`egrep -he 'End: Showdown' $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_SHOWDOWN_TOURNAMENT=$(incrementSitePropertyInDB "hand_ends_showdown_tournament" $HAND_ENDS_SHOWDOWN_TOURNAMENT)
HAND_ENDS_PREFLOP_CASH=`egrep -he 'End: PreFlop' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_PREFLOP_CASH=$(incrementSitePropertyInDB "hand_ends_preflop_cash" $HAND_ENDS_PREFLOP_CASH)
HAND_ENDS_FLOP_CASH=`egrep -he 'End: Flop' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_FLOP_CASH=$(incrementSitePropertyInDB "hand_ends_flop_cash" $HAND_ENDS_FLOP_CASH)
HAND_ENDS_TURN_CASH=`egrep -he 'End: Turn' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_TURN_CASH=$(incrementSitePropertyInDB "hand_ends_turn_cash" $HAND_ENDS_TURN_CASH)
HAND_ENDS_RIVER_CASH=`egrep -he 'End: River' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_RIVER_CASH=$(incrementSitePropertyInDB "hand_ends_river_cash" $HAND_ENDS_RIVER_CASH)
HAND_ENDS_SHOWDOWN_CASH=`egrep -he 'End: Showdown' $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
HAND_ENDS_SHOWDOWN_CASH=$(incrementSitePropertyInDB "hand_ends_showdown_cash" $HAND_ENDS_SHOWDOWN_CASH)

# game hands (holdem)
ROYAL_FLUSHES=`egrep -he '.*shows.*Royal' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
ROYAL_FLUSHES=$(incrementGameHandInDB "holdem" "royal_flush" $ROYAL_FLUSHES)
STRAIGHT_FLUSH=`egrep -he '.*shows.*Straight Flush' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT_FLUSH=$(incrementGameHandInDB "holdem" "straight_flush" $STRAIGHT_FLUSH)
QUADS=`egrep -he '.*shows.*Four of a Kind' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
QUADS=$(incrementGameHandInDB "holdem" "four_of_a_kind" $QUADS)
FULL_HOUSE=`egrep -he '.*shows.*Full House' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
FULL_HOUSE=$(incrementGameHandInDB "holdem" "full_house" $FULL_HOUSE)
FLUSH=`egrep -he '.*shows.*Flush' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
FLUSH=$(incrementGameHandInDB "holdem" "flush" $FLUSH)
STRAIGHT=`egrep -he '.*shows.*Straight' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT=$(incrementGameHandInDB "holdem" "straight" $STRAIGHT)
THREE_KIND=`egrep -he '.*shows.*Three of a Kind' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
THREE_KIND=$(incrementGameHandInDB "holdem" "three_of_a_kind" $THREE_KIND)
TWO_PAIR=`egrep -he '.*shows.*Two Pair' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
TWO_PAIR=$(incrementGameHandInDB "holdem" "two_pair" $TWO_PAIR)
PAIR=`egrep -he '.*shows.*a Pair' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
PAIR=$(incrementGameHandInDB "holdem" "pair" $PAIR)
HIGH_CARD=`egrep -he '.*shows.*High Card' $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
HIGH_CARD=$(incrementGameHandInDB "holdem" "high_card" $HIGH_CARD)

# game hands (omaha)
ROYAL_FLUSHES_OMAHA=`egrep -he '.*shows.*Royal' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
ROYAL_FLUSHES_OMAHA=$(incrementGameHandInDB "omaha" "royal_flush" $ROYAL_FLUSHES_OMAHA)
STRAIGHT_FLUSH_OMAHA=`egrep -he '.*shows.*Straight Flush' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT_FLUSH_OMAHA=$(incrementGameHandInDB "omaha" "straight_flush" $STRAIGHT_FLUSH_OMAHA)
QUADS_OMAHA=`egrep -he '.*shows.*Four of a Kind' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
QUADS_OMAHA=$(incrementGameHandInDB "omaha" "four_of_a_kind" $QUADS_OMAHA)
FULL_HOUSE_OMAHA=`egrep -he '.*shows.*Full House' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
FULL_HOUSE_OMAHA=$(incrementGameHandInDB "omaha" "full_house" $FULL_HOUSE_OMAHA)
FLUSH_OMAHA=`egrep -he '.*shows.*Flush' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
FLUSH_OMAHA=$(incrementGameHandInDB "omaha" "flush" $FLUSH_OMAHA)
STRAIGHT_OMAHA=`egrep -he '.*shows.*Straight' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
STRAIGHT_OMAHA=$(incrementGameHandInDB "omaha" "straight" $STRAIGHT_OMAHA)
THREE_KIND_OMAHA=`egrep -he '.*shows.*Three of a Kind' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
THREE_KIND_OMAHA=$(incrementGameHandInDB "omaha" "three_of_a_kind" $THREE_KIND_OMAHA)
TWO_PAIR_OMAHA=`egrep -he '.*shows.*Two Pair' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
TWO_PAIR_OMAHA=$(incrementGameHandInDB "omaha" "two_pair" $TWO_PAIR_OMAHA)
PAIR_OMAHA=`egrep -he '.*shows.*a Pair' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
PAIR_OMAHA=$(incrementGameHandInDB "omaha" "pair" $PAIR_OMAHA)
HIGH_CARD_OMAHA=`egrep -he '.*shows.*High Card' $GREP_FILE_PATTERN_OMAHA | wc -l | sed -e 's/^[[:space:]]*//'`
HIGH_CARD_OMAHA=$(incrementGameHandInDB "omaha" "high_card" $HIGH_CARD_OMAHA)

# process site pocket pairs
echo "[$(date +'%I:%M:%S')] → Processing all site pocket pairs..."
for CARD in "${HANDS[@]}"
do
  echo "[$(date +'%I:%M:%S')] Processing [$CARD $CARD]..."
  POCKET_PAIR=`egrep -he "Seat.*\[$CARD\w $CARD\w\]" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR=$(incrementPocketPairStatInDB "$CARD$CARD" "total" $POCKET_PAIR)
  POCKET_PAIR_HANDS_WON=`egrep -h "^.* \(\+.*\) (\[$CARD\w $CARD\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_WON=$(incrementPocketPairStatInDB "$CARD$CARD" "total_won" $POCKET_PAIR_HANDS_WON)
  POCKET_PAIR_HANDS_WON_SHOWDOWN=`egrep -h "^.* \(\+.*\) (\[$CARD\w $CARD\w\]) Showdown" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_WON_SHOWDOWN=$(incrementPocketPairStatInDB "$CARD$CARD" "total_won_at_showdown" $POCKET_PAIR_HANDS_WON_SHOWDOWN)
  POCKET_PAIR_HANDS_LOST=`egrep -h "^.* \(\-.*\) (\[$CARD\w $CARD\w\])" $GREP_FILE_PATTERN_HOLDEM | wc -l | sed -e 's/^[[:space:]]*//'`
  POCKET_PAIR_HANDS_LOST=$(incrementPocketPairStatInDB "$CARD$CARD" "lost" $POCKET_PAIR_HANDS_LOST)
done
echo ""

# generate player data (hole card counts, tournament/cash stats, etc) and winnings
for i in "${!PLAYERS[@]}"; do
  PLAYER="${PLAYERS[$i]}"
  NOW="$(date +'%I:%M:%S')"
  echo "[$NOW] → Processing all cards and stats for $PLAYER ..."

  # count the total hands played and then update the database
  PLAYER_TOTAL_HANDS_DEALT=`egrep -he "Seat [0-9]+: $PLAYER \(.*\) \[.*\]" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_TOTAL_HANDS_DEALT=$(incrementPlayerStatInDB "$PLAYER" "total_hands_dealt" $PLAYER_TOTAL_HANDS_DEALT)

  # if this player has no cards, don't do anything
  if [[ $PLAYER_TOTAL_HANDS_DEALT == 0 ]]; then
    continue
  fi

  # player tournament stats
  PLAYER_FOLDED_HANDS_TOURNAMENT=`egrep -he "^$PLAYER folds" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_FOLDED_HANDS_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "folded_hands_tournament" $PLAYER_FOLDED_HANDS_TOURNAMENT)
  PLAYER_SHOWN_HANDS_TOURNAMENT=`egrep -he "^$PLAYER shows" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_SHOWN_HANDS_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "shown_hands_tournament" $PLAYER_SHOWN_HANDS_TOURNAMENT)
  PLAYER_REFUNDED_HANDS_TOURNAMENT=`egrep -he "^$PLAYER refunded" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_REFUNDED_HANDS_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "refunded_hands_tournament" $PLAYER_REFUNDED_HANDS_TOURNAMENT)
  PLAYER_WON_HANDS_TOURNAMENT=`egrep -he "^$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_WON_HANDS_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "won_hands_tournament" $PLAYER_WON_HANDS_TOURNAMENT)

  PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT=`egrep -he "^$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_TOURNAMENT | egrep -o "\(.*\)" | egrep -oe '\([0-9]{2,}\.?.*\)' | tr -d '()' | awk '{s+=$1} END {print s}'`
  if [[ -z $PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT ]]; then
    PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT=0
  fi
  PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "total_won_pot_size_tournament" $PLAYER_TOTAL_WON_POT_SIZE_TOURNAMENT)

  PLAYER_ALL_INS_TOURNAMENT=`egrep -he "^$PLAYER .*\(All-in\)" $GREP_FILE_PATTERN_TOURNAMENT | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_ALL_INS_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "all_ins_tournament" $PLAYER_ALL_INS_TOURNAMENT)
  PLAYER_HANDS_PLAYED_TOURNAMENT=`python scripts/hands-played.py --player $PLAYER --pattern "$GREP_FILE_PATTERN_TOURNAMENT"`
  PLAYER_HANDS_PLAYED_TOURNAMENT=$(incrementPlayerStatInDB "$PLAYER" "hands_played_tournament" $PLAYER_HANDS_PLAYED_TOURNAMENT)
  PLAYER_NUMBER_OF_TOURNAMENTS=`egrep -he "=$PLAYER " $GREP_FILE_PATTERN_TOURNAMENT_RESULTS | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_NUMBER_OF_TOURNAMENTS=$(incrementPlayerStatInDB "$PLAYER" "tournaments_entered" $PLAYER_NUMBER_OF_TOURNAMENTS)

  # player cash stats
  PLAYER_FOLDED_HANDS_CASH=`egrep -he "^$PLAYER folds" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_FOLDED_HANDS_CASH=$(incrementPlayerStatInDB "$PLAYER" "folded_hands_cash" $PLAYER_FOLDED_HANDS_CASH)
  PLAYER_SHOWN_HANDS_CASH=`egrep -he "^$PLAYER shows" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_SHOWN_HANDS_CASH=$(incrementPlayerStatInDB "$PLAYER" "shown_hands_cash" $PLAYER_SHOWN_HANDS_CASH)
  PLAYER_REFUNDED_HANDS_CASH=`egrep -he "^$PLAYER refunded" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_REFUNDED_HANDS_CASH=$(incrementPlayerStatInDB "$PLAYER" "refunded_hands_cash" $PLAYER_REFUNDED_HANDS_CASH)    
  PLAYER_WON_HANDS_CASH=`egrep -he "^$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_WON_HANDS_CASH=$(incrementPlayerStatInDB "$PLAYER" "won_hands_cash" $PLAYER_WON_HANDS_CASH)

  PLAYER_TOTAL_WON_POT_SIZE_CASH=`egrep -he "^$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | egrep -o "\(.*\)" | egrep -oe '\([0-9]{1,}\.?.*\)' | tr -d '()' | awk '{s+=$1} END {print s}'`
  if [[ -z $PLAYER_TOTAL_WON_POT_SIZE_CASH ]]; then
    PLAYER_TOTAL_WON_POT_SIZE_CASH=0
  fi

  PLAYER_TOTAL_WON_POT_SIZE_CASH=$(incrementPlayerStatInDB "$PLAYER" "total_won_pot_size_cash" $PLAYER_TOTAL_WON_POT_SIZE_CASH)
  PLAYER_ALL_INS_CASH=`egrep -he "^$PLAYER .*\(All-in\)" $GREP_FILE_PATTERN_CASH | wc -l | sed -e 's/^[[:space:]]*//'`
  PLAYER_ALL_INS_CASH=$(incrementPlayerStatInDB "$PLAYER" "all_ins_cash" $PLAYER_ALL_INS_CASH)
  PLAYER_HANDS_PLAYED_CASH=`python scripts/hands-played.py --player $PLAYER --pattern "$GREP_FILE_PATTERN_CASH"`
  PLAYER_HANDS_PLAYED_CASH=$(incrementPlayerStatInDB "$PLAYER" "hands_played_cash" $PLAYER_HANDS_PLAYED_CASH)
  
  # compare the currently known largest pot won to the largest one from the sample set for this sync
  CURRENT_BIGGEST_CASH_HAND=$(getPlayerStatFromDB "$PLAYER" "largest_pot_won_cash")
  PLAYER_BIGGEST_CASH_HAND=`egrep -ho "^$PLAYER wins (Side Pot [0-9]|Main Pot|Pot) \(.*\)" $GREP_FILE_PATTERN_CASH | egrep -o "\(.*\)" | egrep -o "[0-9,.]+" | sort -n | tail -n 1`
  if [[ -z $PLAYER_BIGGEST_CASH_HAND ]]; then
    PLAYER_BIGGEST_CASH_HAND=0
  fi

  # if the largest pot is the new record, then set it in the DB
  if (( $(echo "$PLAYER_BIGGEST_CASH_HAND > $CURRENT_BIGGEST_CASH_HAND" | bc -l) )); then
    setPlayerStatInDB "$PLAYER" "largest_pot_won_cash" $PLAYER_BIGGEST_CASH_HAND
  fi

  # process all hole cards dealt to the player
  for FIRST_CARD in "${HANDS[@]}"
  do
    for SECOND_CARD in "${HANDS[@]}"
    do
      PLAYER_HOLE_CARD_COUNT=`egrep -oh "Seat [0-9]+: $PLAYER \(.*\) (\[$FIRST_CARD\w $SECOND_CARD\w\])" $GREP_FILE_PATTERN_ALL | wc -l | sed -e 's/^[[:space:]]*//'`
      UPDATE_PLAYER_SPECIFIC_HAND_SQL="UPDATE player_hands SET cards_$FIRST_CARD$SECOND_CARD = cards_$FIRST_CARD$SECOND_CARD + $PLAYER_HOLE_CARD_COUNT WHERE name = '$PLAYER'"
      executeSQL "$UPDATE_PLAYER_SPECIFIC_HAND_SQL"
    done
  done
done

for i in "${!PLAYERS[@]}"; do
  PLAYER="${PLAYERS[$i]}"
  NOW="$(date +'%I:%M:%S')"
  echo "[$NOW] → Updating tournament and cash results for $PLAYER ..."

  # update player tournament cashes
  updatePlayerNumberOfCashes "$PLAYER"

  # update player buy-ins
  updatePlayerBuyInTotal "$PLAYER"

  # update player tournament gross winnings
  updatePlayerTournamentWinnings "$PLAYER"

  # update player cash total
  updatePlayerCashTotal "$PLAYER"
  echo ""
done

# finally, update the last sync time
updateLastSync
