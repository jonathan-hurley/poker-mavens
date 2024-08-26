#!/usr/bin/env bash

# the name of the poker site if not already set
POKER_SITE_NAME=${POKER_SITE_NAME:-"Your Poker Club"}

# POKER_MAVENS_HOME_DIR=
case "$(uname -s)" in
   Darwin)
     ;;

   Linux)
     ;;

   CYGWIN*|MINGW32*|MSYS*|MINGW*)
    # bash on windows has problems with spaces in the directory names so use one without spaces
    # first check to see if PM7 is installed and use that, otherwise check for PM6
    POKER_MAVENS6_HOME_DIR="/c/Users/Administrator/AppData/Roaming/pokerm~1"
    POKER_MAVENS7_HOME_DIR="/c/Users/Public/Documents/Briggs~1/PokerM~1"   

    if [ -d "$POKER_MAVENS7_HOME_DIR" ] 
    then
      POKER_MAVENS_HOME_DIR=$POKER_MAVENS7_HOME_DIR
    else
      POKER_MAVENS_HOME_DIR=$POKER_MAVENS6_HOME_DIR
    fi

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