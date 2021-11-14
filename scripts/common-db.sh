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
  echo 

  LAST_SYNC_DATE=$(getSitePropertyFromDB "last_scan")
  echo "→ Copying hand history files since $LAST_SYNC_DATE from $PM_DATA_HAND_HISTORY_DIR to $ALL_HANDS_SYNC_TEMP_DIR..."
  find $PM_DATA_HAND_HISTORY_DIR -maxdepth 1 -type f -newermt "$LAST_SYNC_DATE" -exec cp "{}" $ALL_HANDS_SYNC_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $ALL_HANDS_SYNC_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT new hand history files since $LAST_SYNC_DATE"

  echo "→ Copying log files since $LAST_SYNC_DATE from $PM_DATA_HAND_HISTORY_DIR to $LOG_TEMP_DIR..."
  find $PM_DATA_LOGS_DIR -maxdepth 1 -type f -newermt "$LAST_SYNC_DATE" -exec cp "{}" $LOG_TEMP_DIR  \;
  FILE_COUNT=$(ls -l $LOG_TEMP_DIR | wc -l | sed -e 's/^[[:space:]]*//')
  echo "→ $FILE_COUNT new log files since $LAST_SYNC_DATE"
  echo ""

  # touch a simple file in this directory just to ensure if there are no files above, our greps don't fail
  touch "$ALL_HANDS_SYNC_TEMP_DIR/marker"
  touch "$CASH_TEMP_DIR/marker"
  touch "$TOURNMANENT_TEMP_DIR/marker"
  touch "$HOLDEM_TEMP_DIR/marker"
  touch "$OMAHA_TEMP_DIR/marker"
  touch "$LOG_TEMP_DIR/marker"

  # copy PM files out to directories for easier grep'ing
  grep -l "Starting tournament" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $TOURNMANENT_TEMP_DIR
  grep -L "Starting tournament" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $CASH_TEMP_DIR
  egrep -l -m 1 "Game: (.*?)Hold'em" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $HOLDEM_TEMP_DIR
  egrep -l -m 1 "Game: (.*?)Omaha" $ALL_HANDS_SYNC_TEMP_DIR/* | xargs -r -d "\n" cp -t $OMAHA_TEMP_DIR  
}

# updates the last sync to now
function updateLastSync() {
  NOW=$(date +"%D %T")
  echo "→ Updating last scan time to $NOW"
  echo ""
  setSitePropertyInDB "last_scan" "$NOW"
}

