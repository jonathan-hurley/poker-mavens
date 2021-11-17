#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common-db.sh"

HANDS=( "A" "K" "Q" "J" "T" "9" "8" "7" "6" "5" "4" "3" "2" )

# now that the databae is done, let's generate HTML
DATE=`date "+Generated on %B %d, %Y"`

PLAYER_NAV_BODY=""
ALL_PLAYERS_BODY=""

for i in "${!PLAYERS[@]}"; do 
  PLAYER="${PLAYERS[$i]}"

  # first pill selected
  ACTIVE=""
  SELECTED="false"
  if [[ $i -eq 0 ]]; then
    ACTIVE="active"
    SELECTED="true"
  fi

  # table body template for this player
  PLAYER_HOLE_CARDS_TEMPLATE="
            <div class=\"tab-pane fade show $ACTIVE\" id=\"v-pills-$PLAYER\" role=\"tabpanel\" aria-labelledby=\"v-pills-$PLAYER-tab\">
              <div class=\"table100 ver1 smallhead m-b-50\">
                <div class=\"table100-head\">
                  <table>
                    <thead>
                      <tr class=\"row100 head\">
                        <th class=\"cell100 playerpocketpair-column-header\"></th>
                        <th class=\"cell100 playerpocketpair-column-header\">A</th>
                        <th class=\"cell100 playerpocketpair-column-header\">K</th>
                        <th class=\"cell100 playerpocketpair-column-header\">Q</th>
                        <th class=\"cell100 playerpocketpair-column-header\">J</th>
                        <th class=\"cell100 playerpocketpair-column-header\">T</th>
                        <th class=\"cell100 playerpocketpair-column-header\">9</th>
                        <th class=\"cell100 playerpocketpair-column-header\">8</th>
                        <th class=\"cell100 playerpocketpair-column-header\">7</th>
                        <th class=\"cell100 playerpocketpair-column-header\">6</th>
                        <th class=\"cell100 playerpocketpair-column-header\">5</th>
                        <th class=\"cell100 playerpocketpair-column-header\">4</th>
                        <th class=\"cell100 playerpocketpair-column-header\">3</th>
                        <th class=\"cell100 playerpocketpair-column-header\">2</th>
                      </tr>
                    </thead>
                  </table>
                </div>

                <div class=\"table100-body js-pscroll\">
                  <table>
                    <tbody>
                      _PLAYER_HOLE_CARD_DATA_
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
  "

  # navigation
  PLAYER_NAV_TR="<a class=\"nav-link small $ACTIVE\" id=\"v-pills-$PLAYER-tab\" data-toggle=\"pill\" href=\"#v-pills-$PLAYER\" role=\"tab\" aria-controls=\"v-pills-$PLAYER\" aria-selected=\"$SELECTED\">$PLAYER</a>"
  PLAYER_NAV_BODY="$PLAYER_NAV_BODY $PLAYER_NAV_TR"

  PLAYER_MOST_COMMON_HAND_COUNT=0
  PLAYER_LEAST_COMMON_HAND_COUNT=99999

  PLAYER_ALL_TRS=""

  # fetch total of all hands dealt for this player
  PLAYER_TOTAL_HANDS_DEALT=$(getPlayerStatFromDB "$PLAYER" "total_hands_dealt")
  if [[ $PLAYER_TOTAL_HANDS_DEALT -eq 0 ]]; then
    continue
  fi
  
  for FIRST_CARD in "${HANDS[@]}"
  do
    ROW_TR="<tr class=\"row100 body\">_PLAYER_TD_</tr>"
    ROW_ALL_TDS="<td class=\"playerpocketpair-cell\">$FIRST_CARD</td>"    
    for SECOND_CARD in "${HANDS[@]}"
    do
      # start out adding AK to KA to get the total "AK" hands
      # but if both cards are equal, do incorrectly double the PP
      PLAYER_HOLE_CARD_COUNT_SQL="SELECT cards_$FIRST_CARD$SECOND_CARD + cards_$SECOND_CARD$FIRST_CARD FROM player_hands WHERE name = '$PLAYER'"
      if [[ "$FIRST_CARD" == "$SECOND_CARD" ]]; then
        PLAYER_HOLE_CARD_COUNT_SQL="SELECT cards_$FIRST_CARD$SECOND_CARD FROM player_hands WHERE name = '$PLAYER'"
      fi

      PLAYER_HOLE_CARD_COUNT=`executeSQL "$PLAYER_HOLE_CARD_COUNT_SQL"`
      
      PLAYER_HOLE_CARD_COUNT_PCT=$(bc <<< "scale=4; x = $PLAYER_HOLE_CARD_COUNT / $PLAYER_TOTAL_HANDS_DEALT * 100; scale = 2; x / 1")
      PLAYER_HOLE_CARD_COUNT_PCT=$(printf "%.2f" $PLAYER_HOLE_CARD_COUNT_PCT)
      ROW_ALL_TDS="$ROW_ALL_TDS <td class=\"playerstats-cell\">$PLAYER_HOLE_CARD_COUNT<br/>($PLAYER_HOLE_CARD_COUNT_PCT%)</td>"

    # see if this is the most common hand so far
    if [[ $PLAYER_HOLE_CARD_COUNT -gt $PLAYER_MOST_COMMON_HAND_COUNT ]]; then
      PLAYER_MOST_COMMON_HAND_COUNT=$PLAYER_HOLE_CARD_COUNT
    fi

    # see if this is the least common hand so far
    if [[ $PLAYER_HOLE_CARD_COUNT -lt $PLAYER_LEAST_COMMON_HAND_COUNT ]]; then
      PLAYER_LEAST_COMMON_HAND_COUNT=$PLAYER_HOLE_CARD_COUNT
    fi

    done
    ROW_TR="${ROW_TR//_PLAYER_TD_/$ROW_ALL_TDS}"    
    PLAYER_ALL_TRS="$PLAYER_ALL_TRS $ROW_TR"
  done

  # find least and most common hands and replace their HTML so they are colored and  old
  PLAYER_ALL_TRS="${PLAYER_ALL_TRS//\">$PLAYER_LEAST_COMMON_HAND_COUNT<br/ \" style=\"color\: red\; font-weight\: bold\;\">$PLAYER_LEAST_COMMON_HAND_COUNT<br}"
  PLAYER_ALL_TRS="${PLAYER_ALL_TRS//\">$PLAYER_MOST_COMMON_HAND_COUNT<br/ \" style=\"color\: green\; font-weight\: bold\;\">$PLAYER_MOST_COMMON_HAND_COUNT<br}"

  PLAYER_HOLE_CARDS_DATA="${PLAYER_HOLE_CARDS_TEMPLATE//_PLAYER_HOLE_CARD_DATA_/$PLAYER_ALL_TRS}"
  ALL_PLAYERS_BODY="$ALL_PLAYERS_BODY $PLAYER_HOLE_CARDS_DATA"
done

HTML_CONTENT=$(awk -v r="$PLAYER_NAV_BODY" '{gsub(/_PLAYERS_NAVIGATION_/,r)}1' templates/player-hands.tmpl)
HTML_CONTENT="${HTML_CONTENT//_PLAYER_HOLE_CARD_BODY_/$ALL_PLAYERS_BODY}"

# add generation date
HTML_CONTENT="${HTML_CONTENT//_GENERATED_ON_/$DATE}"
HTML_CONTENT=`tidy -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $HTML_CONTENT`
# print it to the file
echo "$HTML_CONTENT" > web/player-cards.html
