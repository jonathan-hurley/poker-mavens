#!/usr/bin/env bash

# the name of the poker site
POKER_SITE_NAME="Your Poker Club"

# POKER_MAVENS_HOME_DIR=
case "$(uname -s)" in
   Darwin)
     ;;

   Linux)
     ;;

   CYGWIN*|MINGW32*|MSYS*|MINGW*)
    # bash on windows has problems with spaces in the directory names
    POKER_MAVENS_HOME_DIR="/c/Users/Administrator/AppData/Roaming/pokerm~1/"
     ;;

   # Add here more strings to compare
   # See correspondence table at the bottom of this answer
   *)
     ;;
esac