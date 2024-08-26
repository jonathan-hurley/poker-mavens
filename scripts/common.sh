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
requiredCommands=( grep bc sed tidy sqlite3 )
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
export TOURNEY_RESULTS_TEMP_DIR="${TOURNEY_RESULTS_TEMP_DIR:-`mktemp -d`}"
export LOG_TEMP_DIR="${LOG_TEMP_DIR:-`mktemp -d`}"

# define grep file patterns against temp directories
export GREP_FILE_PATTERN_TOURNAMENT="$TOURNMANENT_TEMP_DIR/*"
export GREP_FILE_PATTERN_CASH="$CASH_TEMP_DIR/*"
export GREP_FILE_PATTERN_HOLDEM="$HOLDEM_TEMP_DIR/*"
export GREP_FILE_PATTERN_OMAHA="$OMAHA_TEMP_DIR/*"
export GREP_FILE_PATTERN_LOG="$LOG_TEMP_DIR/*"
export GREP_FILE_PATTERN_ALL="$ALL_HANDS_SYNC_TEMP_DIR/*"
export GREP_FILE_PATTERN_TOURNAMENT_RESULTS="$TOURNEY_RESULTS_TEMP_DIR/*"

# the array of hands to create combinations for
export HANDS=( "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2" )

# calculates the average position that a player finishes the tournament
# for tournaments with re-entry, we have to use tail -1 in order to only take the last entry
function calculatePlayerAverageTournmanentFinish(){
  PLAYER=$1

  TOTAL_FINISHES=0
  SUM_FINISH_POSITION=0
  TOURNAMENT_FILES=$(grep -E -l "Place[0-9]+=$PLAYER " $PM_DATA_TOURNEY_DIR/*)  
  while read -r TOURNAMENT_FILE; do
    # find the player's finish position
    FINISH_POSITION=`grep -E -oh "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | tail -1 | grep -E -oh "Place[0-9]+=" | grep -E -o "[0-9]+" | sed -e 's/^[[:space:]]*//'`
    if [[ -z $FINISH_POSITION ]]; then      
      continue
    fi

    TOTAL_FINISHES=$(( $TOTAL_FINISHES + 1 ))

    # see if there were mulitple finishes
    # first find the place (Place1=)
    FINISH_POSITION_SUBSTRING=`grep -E -oh "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | tail -1 | grep -E -oh "Place[0-9]+="`

    # now find the number of finishes in that position (1 or 2 or 3)
    FINISH_POSITIONS_SPLIT_COUNT=`grep -E -oh "$FINISH_POSITION_SUBSTRING" "$TOURNAMENT_FILE" | wc -l | sed -e 's/^[[:space:]]*//'`
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

# gets a date formatted string representing 11:59:59 PM yesterday
function getYesterday() {
  # we need to convert between date formats for awk, but BSD vs GNU date take different arguments
  if date --version >/dev/null 2>&1 ; then
      YESTERDAY=$(date -d "$date -1 days" +"%Y-%m-%d 23:59:59")
  else
      YESTERDAY=$(date -j -v -1d +"%Y-%m-%d 23:59:59")
  fi

  echo "$YESTERDAY"
}

# gets the player's display name if it exists, or returns the original argument
function getPlayerName() {
  PLAYER_NAME=$1
  if [ ${PLAYER_NAME_MAPPINGS[$PLAYER_NAME]+_} ]; then
    PLAYER_NAME=${PLAYER_NAME_MAPPINGS[$PLAYER_NAME]}
  fi

  echo $PLAYER_NAME
}
