#!/usr/bin/env bash

# Lists all players to generate data for
PLAYERS=( "Player-1"
"Player-2"
)

# Missing cash data
declare -A PLAYER_CASH_OFFSET=(
  ["Player-1"]="0"
  ["Player-2"]="240.50"
  ["default"]="0"
)

# Missing tournament data
declare -A PLAYER_TOURNAMENT_WINNINGS_OFFSET=(
  ["Player-1"]="0"
  ["Player-2"]="240.50"
  ["default"]="0"
)

# Missing number of tournament cashes data
declare -A PLAYER_NUM_CASHES_OFFSET=(
  ["Player-1"]="1"
  ["Player-2"]="2"
  ["default"]="0"
)