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

    # add required GNU programs to the path
    PATH="$PATH:/c/Program Files (x86)/GnuWin32/bin"
    PATH="$PATH:/c/Program Files/tidy 5.8.0/bin"
     ;;

   # Add here more strings to compare
   # See correspondence table at the bottom of this answer
   *)
     ;;
esac

# locale for printing numbers (1000 vs 1,000)
LANG=${LANG:="en_US.UTF-8"}
export LANG