#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/players.sh"
. "$DIR/common.sh"

SQLITE_DATABASE_FILE="database/poker-mavens-site.db"
SQLITE_CMD="sqlite3 $SQLITE_DATABASE_FILE"

# initializes the database if the file does not exist
function initializeDatabase() {
  if [[ -f "$SQLITE_DATABASE_FILE" ]]; then
    echo "→ Existing database found at $SQLITE_DATABASE_FILE"
  else
    echo "→ Creating database at $SQLITE_DATABASE_FILE"
    executeSQL ".read database/poker-mavens-site.sql"
  fi
}

# executes the SQL passed in as the first argument
function executeSQL() {
  SQL="$1"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  if [[ -n $RESULT ]]; then
    echo $RESULT
  fi
}

# gets a specific value from the site table
function getSitePropertyFromDB() {
  PROPERTY="$1"
  SQL="SELECT $PROPERTY FROM site WHERE name = 'poker-mavens-site'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  echo $RESULT
}

# gets a specific value from the site table
function incrementSitePropertyInDB() {
  PROPERTY="$1"
  VALUE=$2

  SQL="UPDATE site SET $PROPERTY = $PROPERTY + $VALUE WHERE name = 'poker-mavens-site'"
  executeSQL "$SQL"

  getSitePropertyFromDB $PROPERTY
}

# sets a specific value from the site table
function setSitePropertyInDB() {
  PROPERTY="$1"
  VALUE="$2"

  SQL="UPDATE site SET $PROPERTY = '$VALUE' WHERE name = 'poker-mavens-site'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  if [[ -n $RESULT ]]; then
    echo $RESULT
  fi
}

# gets a specific value from the game info table
function getGameHandFromDB() {
  GAME="$1"
  HAND="$2"
  SQL="SELECT $HAND FROM game_hands WHERE name = '$GAME'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  echo $RESULT
}

# gets a specific value from the game info table
function incrementGameHandInDB() {
  GAME="$1"
  HAND="$2"
  VALUE=$3

  SQL="UPDATE game_hands SET $HAND = $HAND + $VALUE WHERE name = '$GAME'"
  executeSQL "$SQL"

  getGameHandFromDB $GAME $HAND
}

# gets a specific value from the player stats table
function getPlayerStatFromDB() {
  PLAYER="$1"
  STAT="$2"
  SQL="SELECT $STAT FROM player_summary WHERE name = '$PLAYER'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  echo $RESULT
}

# set a specific value for the player stats table
function setPlayerStatInDB() {
  PLAYER="$1"
  STAT="$2"
  VALUE=$3
  
  SQL="UPDATE player_summary SET $STAT = $VALUE WHERE name = '$PLAYER'"
  executeSQL "$SQL"
}

# gets a specific value from the player stats table
function incrementPlayerStatInDB() {
  PLAYER="$1"
  STAT="$2"
  VALUE=$3
  
  SQL="UPDATE player_summary SET $STAT = $STAT + $VALUE WHERE name = '$PLAYER'"
  executeSQL "$SQL"

  getPlayerStatFromDB $PLAYER $STAT
}

# gets a specific value from the player stats table
function getPlayerHandFromDB() {
  PLAYER="$1"
  HAND="$2"
  SQL="SELECT $HAND FROM player_hands WHERE name = '$PLAYER'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  echo $RESULT
}

# gets a specific value from the player stats table
function incrementPocketPairStatInDB() {
  PP="$1"
  STAT="$2"
  VALUE=$3
  
  SQL="UPDATE pocket_pairs SET $STAT = $STAT + $VALUE WHERE pair = '$PP'"
  executeSQL "$SQL"

  getPocketPairStatFromDB $PLAYER $STAT
}

# gets a specific value from the player stats table
function getPocketPairStatFromDB() {
  PP="$1"
  STAT="$2"
  SQL="SELECT $STAT FROM pocket_pairs WHERE pair = '$PP'"
  RESULT=`eval $SQLITE_CMD "\"$SQL\""`
  echo $RESULT
}

# checks the specified table to see if the user exists, and creates a blank record if they don't
# assumes the column is called "name"
function insertPlayerIfNotExists(){
  PLAYER=$1
  TABLE_NAME=$2

  SELECT_PLAYER_EXISTS_SQL="SELECT COUNT(*) FROM $TABLE_NAME WHERE name = '$PLAYER'"
  RECORD_COUNT=`executeSQL "$SELECT_PLAYER_EXISTS_SQL"`
  if [[ $RECORD_COUNT -eq 0 ]]; then    
    INSERT_PLAYER_SQL="INSERT INTO $TABLE_NAME (name) VALUES ('$PLAYER')"
    executeSQL "$INSERT_PLAYER_SQL"
  fi
}

# iterates over all tables and seeds empty rolls if any player does not exist
function ensurePlayersInTables(){
  echo ""
  echo "========= SYNCHRONIZING PLAYERS ACROSS ALL TABLES ========="

  # players
  for PLAYER in "${PLAYERS[@]}"
  do
    echo "→ Seeding $PLAYER in the database..."
    insertPlayerIfNotExists "$PLAYER" players
    insertPlayerIfNotExists "$PLAYER" player_summary
    insertPlayerIfNotExists "$PLAYER" player_hands

    # cash offset
    if [ ${PLAYER_CASH_OFFSET[$PLAYER]+_} ]; then
      OFFSET=${PLAYER_CASH_OFFSET[$PLAYER]}
      setPlayerStatInDB "$PLAYER" "offset_cash_winnings" $OFFSET
    fi

    # tournament offset
    if [ ${PLAYER_TOURNAMENT_WINNINGS_OFFSET[$PLAYER]+_} ]; then
      OFFSET=${PLAYER_TOURNAMENT_WINNINGS_OFFSET[$PLAYER]}
      setPlayerStatInDB "$PLAYER" "offset_tournament_winnings" $OFFSET
    fi

    # tournament cashes offset
    if [ ${PLAYER_NUM_CASHES_OFFSET[$PLAYER]+_} ]; then
      OFFSET=${PLAYER_NUM_CASHES_OFFSET[$PLAYER]}
      setPlayerStatInDB "$PLAYER" "offset_tournament_num_cashes" $OFFSET
    fi
  done

  echo ""
}

# finds all of the files since the last sync and copies them to a temp location
function copyFilesSinceLastSync() {
  echo "=========   PREPARING DIRECTORIES   ========="
  echo "Copying files from $PM_DATA_HAND_HISTORY_DIR to temp directories..."
  echo "  All        → $ALL_HANDS_SYNC_TEMP_DIR"
  echo "  Cash       → $CASH_TEMP_DIR"
  echo "  Tournament → $TOURNMANENT_TEMP_DIR"
  echo "  Hold 'Em   → $HOLDEM_TEMP_DIR"
  echo "  Omaha      → $OMAHA_TEMP_DIR"
  echo "  Logs       → $LOG_TEMP_DIR"
  echo "  Tournament Results → $TOURNEY_RESULTS_TEMP_DIR"
  echo 

  # build the date format that the mavens files use (1970-01-01)
  # we cannot copy today's hand history file for processing since it gets appended to during the day
  # and it would end up being double-processed the next time this is run (-not -name "HH$TODAY*")
  TODAY=$(date +"%Y-%m-%d")
  NOW=$(date +"%Y-%m-%d %T")
  LAST_SYNC_DATE_ONLY=$(getPokerMavensFormattedDateOfLastSync)
  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_sync")

  echo "→ Copying Poker Mavens files with the following dates..."
  echo "  Hand history: [$LAST_SYNC_DATE to $NOW] and [$LAST_SYNC_DATE_ONLY] but not [$TODAY]"
  echo "  Tournament files: [$LAST_SYNC_DATE] to [$NOW]"
  echo "  Log files: [$LAST_SYNC_DATE] to [$NOW]"
  echo

  # we simulate "up to yesterday" by dropping all HH files created today
  echo "→ Copying hand history files from $PM_DATA_HAND_HISTORY_DIR to $ALL_HANDS_SYNC_TEMP_DIR..."
  find $PM_DATA_HAND_HISTORY_DIR -maxdepth 1 -type f -not -name "HH$TODAY*" -newermt "$LAST_SYNC_DATE" -exec cp "{}" $ALL_HANDS_SYNC_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $ALL_HANDS_SYNC_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT new hand history files since $LAST_SYNC_DATE"
  echo ""

  # copy hand history files skipped on the last sync date (those skipped above)
  echo "→ Copying hand history files from $PM_DATA_HAND_HISTORY_DIR to $ALL_HANDS_SYNC_TEMP_DIR..."
  find $PM_DATA_HAND_HISTORY_DIR -maxdepth 1 -type f -and -name "HH$LAST_SYNC_DATE_ONLY*" -and -not -name "HH$TODAY*" -exec cp "{}" $ALL_HANDS_SYNC_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $ALL_HANDS_SYNC_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT hand history files which were skipped on $LAST_SYNC_DATE_ONLY but did not match today ($TODAY)"
  echo ""

  # log files can be post-processed incrementally since each line has a timestamp, so get everything since the last sync
  echo "→ Copying log files from $PM_DATA_LOGS_DIR to $LOG_TEMP_DIR..."
  find $PM_DATA_LOGS_DIR -maxdepth 1 -type f -newermt "$LAST_SYNC_DATE" -exec cp "{}" $LOG_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $LOG_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT new log files since $LAST_SYNC_DATE"
  echo ""

  echo "→ Copying tournament results from $PM_DATA_TOURNEY_DIR to $TOURNEY_RESULTS_TEMP_DIR..."
  find $PM_DATA_TOURNEY_DIR -maxdepth 1 -type f -newermt "$LAST_SYNC_DATE" -exec cp "{}" $TOURNEY_RESULTS_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $TOURNEY_RESULTS_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT new tournament files since $LAST_SYNC_DATE"
  echo ""

  # touch a simple file in this directory just to ensure if there are no files above, our greps don't fail
  touch "$ALL_HANDS_SYNC_TEMP_DIR/marker"
  touch "$CASH_TEMP_DIR/marker"
  touch "$TOURNMANENT_TEMP_DIR/marker"
  touch "$HOLDEM_TEMP_DIR/marker"
  touch "$OMAHA_TEMP_DIR/marker"
  touch "$LOG_TEMP_DIR/marker"
  touch "$TOURNEY_RESULTS_TEMP_DIR/marker"

  # copy PM files out to directories for easier grep'ing
  grep -l "Starting tournament" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $TOURNMANENT_TEMP_DIR
  grep -L "Starting tournament" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $CASH_TEMP_DIR
  egrep -l -m 1 "Game: (.*?)Hold'em" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $HOLDEM_TEMP_DIR
  egrep -l -m 1 "Game: (.*?)Omaha" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $OMAHA_TEMP_DIR  
}

# gets the player cash total, including the offset, from the database
# will print (redacted) for any players in the redacted array
function getPlayerCashTotalFromDB() {
  PLAYER=$1

  # if the player's cash must be redacted due to embarassement, then redact it
  if printf '%s\n' "${PLAYERS_CASH_REDACTED[@]}" | grep -q -P "^$PLAYER\$"; then
      echo "(redacted)"
      return
  fi

  # calculate player cash total
  PLAYER_CASH_TOTAL=$(getPlayerStatFromDB "$PLAYER" "cash_winnings")
  OFFSET=$(getPlayerStatFromDB "$PLAYER" "offset_cash_winnings")
  PLAYER_CASH_TOTAL=`bc <<< "$OFFSET + $PLAYER_CASH_TOTAL"`
  echo "$PLAYER_CASH_TOTAL"
}

# updates the last time the database sync ran
function updateLastSync() {
  TODAY=$(date +"%Y-%m-%d %T")
  echo "→ Updating last sync time to $TODAY"
  echo ""
  setSitePropertyInDB "last_sync" "$TODAY"
}

# updates the amount of money a player has spent on buy-ins and rebuys for all tournaments entered
function updatePlayerBuyInTotal(){
  PLAYER=$1

  TOTAL=0
  GROSS_TOTAL=0
  
  TOURNAMENT_FILES=$(egrep -l "Place[0-9]+=$PLAYER " $GREP_FILE_PATTERN_TOURNAMENT_RESULTS)

  # if there are no tournament files then bail
  if [[ -z $TOURNAMENT_FILES ]]; then
    echo "           Tournament buy-ins increased \$$TOTAL since last sync (Total: \$$GROSS_TOTAL)"  
    return
  fi  

  while read -r TOURNAMENT_FILE; do
    BUY_IN=`egrep -h "BuyIn" "$TOURNAMENT_FILE" | egrep -oe "[0-9|.]+\+[0-9]+" | awk '{s+=$1} END {print s}' | bc`
    if [[ -z $BUY_IN ]]; then
      BUY_IN=0
    fi

    REBUYS=`egrep -h "Place[0-9]+=$PLAYER " "$TOURNAMENT_FILE" | egrep -oe "Rebuys:[0-9]+" | tr -d 'Rebuys:'`
    if [[ -z $REBUYS ]]; then
      REBUYS=0
    fi

    TOTAL=$(bc <<< "$TOTAL + $BUY_IN + ($REBUYS * $BUY_IN)")
  done <<< "$TOURNAMENT_FILES"

  GROSS_TOTAL=$(incrementPlayerStatInDB "$PLAYER" "tournament_total_spent" $TOTAL)
  echo "           Tournament buy-ins increased \$$TOTAL since last sync (Total: \$$GROSS_TOTAL)"
}

# uses tourney history to get player cashes
# also handles bounties of the form ($0+$0)
function updatePlayerNumberOfCashes(){
  PLAYER=$1
  NUMBER_OF_CASHES=$(egrep -h "Place[0-9]+=$PLAYER " $GREP_FILE_PATTERN_TOURNAMENT_RESULTS | egrep -oe "\(.*\)" | egrep -v "\(0\)|\(0\+0\)" | tr -d '()' | wc -l | sed -e 's/^[[:space:]]*//')
  if [[ -z $NUMBER_OF_CASHES ]]; then
    NUMBER_OF_CASHES=0
  fi

  TOTAL_NUMBER_OF_CASHES=$(incrementPlayerStatInDB "$PLAYER" "tournament_cashes" $NUMBER_OF_CASHES)
  echo "           Tournament # of Cashes increased by $NUMBER_OF_CASHES since last sync (Total: $TOTAL_NUMBER_OF_CASHES)"
}

# uses tourney history to get player winnings
# also handles bounties of the form ($0+$0)
function updatePlayerTournamentWinnings(){
  PLAYER=$1
  TOURNAMENT_WINNINGS=$(egrep -h "Place[0-9]+=$PLAYER " $GREP_FILE_PATTERN_TOURNAMENT_RESULTS | egrep -oe "\(.*\)" | tr -d '()' | bc | awk '{s+=$1}END{print s}')

  if [[ -z $TOURNAMENT_WINNINGS ]]; then
    TOURNAMENT_WINNINGS=0
  fi

  TOTAL_TOURNAMENT_WINNINGS=$(incrementPlayerStatInDB "$PLAYER" "tournament_gross_winnings" $TOURNAMENT_WINNINGS)
  echo "           Tournament winnings increased by \$$TOURNAMENT_WINNINGS since last sync (Total: \$$TOTAL_TOURNAMENT_WINNINGS)"
}

# uses logs to get player cash total
function updatePlayerCashTotal(){
  PLAYER=$1

  # this function has to ensure that files which were partially processed and then were appended to have 
  # already processed lines dropped (based on date via awk)
  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_sync")

  # uses the House|Ring keyword to find money given to the house/ring for a player. 
  # The problem is that it's not for a player, it's for the house, so we need to mutiply by -1 to get the player's amount
  # We used to use the search by game name (ie Sizzler) but can't do that anymore since we want other games to show up
  # This file also works around the "incremental update" issue on a single file by piping results through awk to compare dates
  # from the last time the sync ran
  PLAYER_CASH_CHANGE=$(egrep -h "House\|Ring.*($PLAYER .*)" $GREP_FILE_PATTERN_LOG | awk "\$0 > \"$LAST_SYNC_DATE\"" | egrep -oe "House\|Ring.*balance" | egrep -oe "[-|+][0-9]+(\.[0-9]+)?" | awk '{s+=$1*-1} END {print s}')
  if [[ -z $PLAYER_CASH_CHANGE ]]; then
    PLAYER_CASH_CHANGE=0
  fi

  PLAYER_CASH_TOTAL=$(incrementPlayerStatInDB "$PLAYER" "cash_winnings" $PLAYER_CASH_CHANGE)
  echo "           Cash game profit changed by \$$PLAYER_CASH_CHANGE since $LAST_SYNC_DATE (Total: \$$PLAYER_CASH_TOTAL)"
}

# gets a date formatted string representing 11:59:59 PM on the day before the last sync
function getDayBeforeLastSync() {
  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_sync")

  # determine which version of date to use (BSD vs GNU)
  if date --version >/dev/null 2>&1 ; then
      # convert to ISO to prevent timezone from being taken into account
      DAY_BEFORE_LAST_SYNC=$(date -d "$(date -Iseconds -d "$LAST_SYNC_DATE") - 1 days" +"%Y-%m-%d 23:59:59")
  else
      DAY_BEFORE_LAST_SYNC=$(date -j -v -1d -f "%Y-%m-%d %T" "$LAST_SYNC_DATE" +"%Y-%m-%d 23:59:59")
  fi

  echo "$DAY_BEFORE_LAST_SYNC"
}

# gets a date formatted string representing 00:00:00 on the day of the last sync
function getStartOfDayOfLastSync() {
  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_sync")

  # determine which version of date to use (BSD vs GNU)
  if date --version >/dev/null 2>&1 ; then
      DAY_BEFORE_LAST_SYNC=$(date -d "$LAST_SYNC_DATE" +"%Y-%m-%d 00:00:00")
  else
      DAY_BEFORE_LAST_SYNC=$(date -j -f "%Y-%m-%d %T" "$LAST_SYNC_DATE" +"%Y-%m-%d 00:00:00")
  fi

  echo "$DAY_BEFORE_LAST_SYNC"
}

# Gets a date, formatted to the PM file format, matching the last sync date
function getPokerMavensFormattedDateOfLastSync() {
  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_sync")

  # determine which version of date to use (BSD vs GNU)
  if date --version >/dev/null 2>&1 ; then
      LASY_SYNC_DATE_ONLY=$(date -d "$LAST_SYNC_DATE" +"%Y-%m-%d")
  else
      LASY_SYNC_DATE_ONLY=$(date -j -f "%Y-%m-%d %T" "$LAST_SYNC_DATE" +"%Y-%m-%d")
  fi

  echo "$LASY_SYNC_DATE_ONLY"
}