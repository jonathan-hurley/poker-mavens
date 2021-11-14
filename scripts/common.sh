#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.sh"

# load a custom players file if it exists, otherwise just load the tempalte
if [ -f "$DIR/players.sh" ]; then
    . "$DIR/players.sh"
else
    . "$DIR/players-template.sh"
fi

# exit on missing required variables
requiredVariables=( POKER_MAVENS_HOME_DIR POKER_SITE_NAME )
for requiredVariableName in "${requiredVariables[@]}"
do
  requiredVariable="${!requiredVariableName}"
  if [[ -z $requiredVariable ]]; then
    echo "The config value for $requiredVariableName is not defined"
    exit 1
  fi
done

# check python version
pythonVersion=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
if [[ -z "$pythonVersion" ]]
then
    echo "Python must be installed in order for these scripts to work"
    exit 1
fi

# ensure that command we use are available on the path
requiredCommands=( grep egrep bc sed tidy sqlite3 )
for requiredCommandName in "${requiredCommands[@]}"
do
  command -v $requiredCommandName &> /dev/null
  retVal=$?
  if [ $retVal -ne 0 ]; then
    echo "The command $requiredCommandName is required and was not found on the path."
    exit 1
  fi
done

# set required variables
PM_DATA_TOURNEY_DIR="$POKER_MAVENS_HOME_DIR/TourneyResults"
PM_DATA_HAND_HISTORY_DIR="$POKER_MAVENS_HOME_DIR/HandHistory"
PM_DATA_LOGS_DIR="$POKER_MAVENS_HOME_DIR/Logs"

# define temp directories for easier grep'ing later
export ALL_HANDS_SYNC_TEMP_DIR="${ALL_HANDS_SYNC_TEMP_DIR:-`mktemp -d`}"
export TOURNMANENT_TEMP_DIR="${TOURNMANENT_TEMP_DIR:-`mktemp -d`}"
export CASH_TEMP_DIR="${CASH_TEMP_DIR:-`mktemp -d`}"
export HOLDEM_TEMP_DIR="${HOLDEM_TEMP_DIR:-`mktemp -d`}"
export OMAHA_TEMP_DIR="${OMAHA_TEMP_DIR:-`mktemp -d`}"
export LOG_TEMP_DIR="${LOG_TEMP_DIR:-`mktemp -d`}"

# define grep file patterns against temp directories
export GREP_FILE_PATTERN_TOURNAMENT="$TOURNMANENT_TEMP_DIR/*"
export GREP_FILE_PATTERN_CASH="$CASH_TEMP_DIR/*"
export GREP_FILE_PATTERN_HOLDEM="$HOLDEM_TEMP_DIR/*"
export GREP_FILE_PATTERN_OMAHA="$OMAHA_TEMP_DIR/*"
export GREP_FILE_PATTERN_LOG="$LOG_TEMP_DIR/*"
export GREP_FILE_PATTERN_ALL="$ALL_HANDS_SYNC_TEMP_DIR/*"
export GREP_FILE_PATTERN_TOURNAMENT_RESULTS="$PM_DATA_TOURNEY_DIR/*"

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
    BUY_IN=`egrep -h "BuyIn" "$TOURNAMENT_FILE" | egrep -oe "[0-9|.]+\+[0-9]+" | awk '{s+=$1} END {print s}' | bc`
    REBUYS=`egrep -h "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | egrep -oe "Rebuys:[0-9]+" | tr -d 'Rebuys:'`
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
  PLAYER_CASH_TOTAL=`egrep -h "House\|Ring.*($PLAYER .*)" $PM_DATA_LOGS_DIR/* | egrep -oe "House\|Ring.*balance" | egrep -oe "[-|+][0-9]+(\.[0-9]+)?" | awk '{s+=$1*-1} END {print s}'`
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
  TOURNAMENT_WINNINGS=$(egrep -h "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/* | egrep -oe "\(.*\)" | tr -d '()' | bc | awk '{s+=$1}END{print s}')

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
  NUMBER_OF_CASHES=$(egrep -h "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/* | egrep -oe "\(.*\)" | egrep -v "\(0\)|\(0\+0\)" | tr -d '()' | wc -l)

  if [ ${PLAYER_NUM_CASHES_OFFSET[$PLAYER]+_} ]; then
    OFFSET=${PLAYER_NUM_CASHES_OFFSET[$PLAYER]}
    NUMBER_OF_CASHES=`bc <<< "$OFFSET + $NUMBER_OF_CASHES"`
  fi

  echo $NUMBER_OF_CASHES
}

# calculates the average position that a player finishes the tournament
# for tournaments with re-entry, we have to use tail -1 in order to only take the last entry
function calculatePlayerAverageTournmanentFinish(){
  PLAYER=$1

  TOTAL_FINISHES=0
  SUM_FINISH_POSITION=0
  TOURNAMENT_FILES=$(egrep -l "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/*)  
  while read -r TOURNAMENT_FILE; do
    # find the player's finish position
    FINISH_POSITION=`egrep -oh "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | tail -1 | egrep -oh "Place[0-9]+=" | egrep -o "[0-9]+" | sed -e 's/^[[:space:]]*//'`
    if [[ -z $FINISH_POSITION ]]; then      
      continue
    fi

    TOTAL_FINISHES=$(( $TOTAL_FINISHES + 1 ))

    # see if there were mulitple finishes
    # first find the place (Place1=)
    FINISH_POSITION_SUBSTRING=`egrep -oh "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | tail -1 | egrep -oh "Place[0-9]+="`

    # now find the number of finishes in that position (1 or 2 or 3)
    FINISH_POSITIONS_SPLIT_COUNT=`egrep -oh "$FINISH_POSITION_SUBSTRING" "$TOURNAMENT_FILE" | wc -l | sed -e 's/^[[:space:]]*//'`    
    if [[ $FINISH_POSITIONS_SPLIT_COUNT -gt 1 ]]; then
      splitSum=0
      counter=1      
      while [ $counter -le  $FINISH_POSITIONS_SPLIT_COUNT ]
      do
        splitSum=$(( $counter + $splitSum ))
        counter=$(( $counter + 1 ))
      done

      FINISH_POSITION=$(bc -l <<< "scale=3; $splitSum / $FINISH_POSITIONS_SPLIT_COUNT")
    fi

    SUM_FINISH_POSITION=$(bc <<< "$SUM_FINISH_POSITION + $FINISH_POSITION")
  done <<< "$TOURNAMENT_FILES"

  AVERAGE_FINISH_POSITION=$(bc <<< "scale=2; $SUM_FINISH_POSITION / $TOTAL_FINISHES")
  echo $AVERAGE_FINISH_POSITION
}
