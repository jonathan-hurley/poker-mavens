#!/usr/bin/env bash

# fail on any error
set -e

scripts/generate-stats.sh
scripts/generate-buy-ins.sh
scripts/generate-winnings.sh

# this is a very intensive script as it counts all 
# hands dealt to a player and then generates a table
# scripts/generate-player-hands.sh
