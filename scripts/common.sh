#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.sh"
. "$DIR/players.sh"

# exit on missing required variables
REQUIRED_VARS=( POKER_MAVENS_HOME_DIR POKER_SITE_NAME )
for REQ_VAR_NAME in "${REQUIRED_VARS[@]}"
do
  REQ_VAR="${!REQ_VAR_NAME}"
  if [[ -z $REQ_VAR ]]; then
    echo "The config value for $REQ_VAR_NAME is not defined"
    exit 1
  fi
done

# check python version
pythonVersion=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
if [[ -z "$pythonVersion" ]]
then
    echo "Python v3.x must be installed in order for these scripts to work" 
    exit 1
fi

# set required variables
PM_DATA_TOURNEY_DIR=$POKER_MAVENS_HOME_DIR/TourneyResults
PM_DATA_HAND_HISTORY_DIR=$POKER_MAVENS_HOME_DIR/HandHistory
PM_DATA_LOGS_DIR=$POKER_MAVENS_HOME_DIR/Logs

# calculate how much money a player has spent on buy-ins
function calculatePlayerBuyInTotal(){
  PLAYER=$1

  TOTAL=0
  TOURNAMENT_FILES=$(egrep -l "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/*)
  
  # no tournaments, no buy-ins, return 0
  if [[ -z $TOURNAMENT_FILES ]]; then
    echo 0
    return 0
  fi
  
  while read -r TOURNAMENT_FILE; do
    BUY_IN=`egrep "BuyIn" "$TOURNAMENT_FILE" | egrep -oe "[0-9|.]+\+[0-9]+" | bc`
    REBUYS=`egrep "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | egrep -oe "Rebuys:[0-9]+" | tr -d 'Rebuys:'`
    if [[ -z $REBUYS ]]; then
      REBUYS=0
    fi

    TOTAL=$(bc <<< "$TOTAL + $BUY_IN + ($REBUYS * $BUY_IN)")
  done <<< "$TOURNAMENT_FILES"

  echo $TOTAL
}

# uses logs to get player cash total
function calculatePlayerCashTotal(){
  PLAYER=$1

  # uses the House|Ring keyword to find money given to the house/ring for a player. 
  # The problem is that it's not for a player, it's for the house, so we need to mutiply by -1 to get the player's amount
  # We used to use the search by game name (ie Sizzler) but can't do that anymore since we want other games to show up
  PLAYER_CASH_TOTAL=`egrep "House\|Ring.*($PLAYER .*)" $PM_DATA_LOGS_DIR/* | egrep -oe "House\|Ring.*balance" | egrep -oe "[-|+][0-9]+(\.[0-9]+)?" | awk '{s+=$1*-1} END {print s}'`
  if [[ -z $PLAYER_CASH_TOTAL ]]; then
    PLAYER_CASH_TOTAL=0
  fi

  if [ ${PLAYER_CASH_OFFSET[$PLAYER]+_} ]; then
    OFFSET=${PLAYER_CASH_OFFSET[$PLAYER]}
    PLAYER_CASH_TOTAL=`bc <<< "$OFFSET + $PLAYER_CASH_TOTAL"`
  fi

  echo "$PLAYER_CASH_TOTAL"
}

# uses tourney history to get player winnings
# also handles bourntys of the form ($0+$0)
function calculatePlayerTournamentWinnings(){
  PLAYER=$1
  TOURNAMENT_WINNINGS=$(egrep "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/* | egrep -oe "\(.*\)" | tr -d '()' | bc | awk '{s+=$1}END{print s}')

  if [[ -z $TOURNAMENT_WINNINGS ]]; then
    TOURNAMENT_WINNINGS=0
  fi

  if [ ${PLAYER_TOURNAMENT_WINNINGS_OFFSET[$PLAYER]+_} ]; then
    OFFSET=${PLAYER_TOURNAMENT_WINNINGS_OFFSET[$PLAYER]}
    TOURNAMENT_WINNINGS=`bc <<< "$OFFSET + $TOURNAMENT_WINNINGS"`
  fi

  echo "$TOURNAMENT_WINNINGS"
}

# uses tourney history to get player cashes
# also handles bourntys of the form ($0+$0)
function calculatePlayerNumberOfCashes(){
  PLAYER=$1
  NUMBER_OF_CASHES=$(egrep "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/* | egrep -oe "\(.*\)" | egrep -v "\(0\)|\(0\+0\)" | tr -d '()' | wc -l)

  if [ ${PLAYER_NUM_CASHES_OFFSET[$PLAYER]+_} ]; then
    OFFSET=${PLAYER_NUM_CASHES_OFFSET[$PLAYER]}
    NUMBER_OF_CASHES=`bc <<< "$OFFSET + $NUMBER_OF_CASHES"`
  fi

  echo $NUMBER_OF_CASHES
}