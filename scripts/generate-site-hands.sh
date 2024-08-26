#!/usr/bin/env bash
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/common-db.sh"

SITE_STATS=( "total_wins" "wins_at_showdown" "wins_no_showdown" )
declare -A SITE_STAT_MAPPINGS=(
  ["total_wins"]="Total Wins"
  ["wins_at_showdown"]="Wins at Showdown"
  ["wins_no_showdown"]="Wins without Showdown"
)

# now that the databae is done, let's generate HTML
DATE=`date "+Generated on %B %d, %Y"`

ALL_STATS_BODY=""
BOOTSTRAP_PILL_NAV_DIV="<div class=\"col-small nav flex-column nav-pills\" role=\"tablist\" aria-orientation=\"vertical\" style=\"padding-right:10px\">"
STAT_NAV_BODY="$BOOTSTRAP_PILL_NAV_DIV"

for SQL_STAT in "${SITE_STATS[@]}"
do
  STAT_DESC="${SITE_STAT_MAPPINGS[$SQL_STAT]}"

  # first pill selected
  ACTIVE=""
  SELECTED="false"
  if [[ $SQL_STAT = "total_wins" ]]; then
    ACTIVE="active"
    SELECTED="true"
  fi

  # table body template for this player
  SITE_HOLE_CARDS_STAT_TEMPLATE="
            <div class=\"tab-pane fade show $ACTIVE\" id=\"v-pills-$SQL_STAT\" role=\"tabpanel\" aria-labelledby=\"v-pills-$SQL_STAT-tab\">
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
                      _SITE_HOLE_CARD_STAT_DATA_
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
  "

  # fetch total of all hands dealt for this player
  TOTAL_HANDS_DEALT=$(getSitePropertyFromDB "total_hands")

  # navigation
  STAT_NAV_TR="<a class=\"nav-link small $ACTIVE\" id=\"v-pills-$SQL_STAT-tab\" data-toggle=\"pill\" href=\"#v-pills-$SQL_STAT\" role=\"tab\" aria-controls=\"v-pills-$SQL_STAT\" aria-selected=\"$SELECTED\">$STAT_DESC</a>"
  STAT_NAV_BODY="$STAT_NAV_BODY $STAT_NAV_TR"

  MOST_COMMON_HAND_COUNT=0
  LEAST_COMMON_HAND_COUNT=999999

  SITE_STAT_ALL_TRS=""
  
  for FIRST_CARD in "${HANDS[@]}"
  do
    ROW_TR="<tr class=\"row100 body\">_SITE_STAT_TD_</tr>"
    ROW_ALL_TDS="<td class=\"playerpocketpair-cell\">$FIRST_CARD</td>"    
    for SECOND_CARD in "${HANDS[@]}"
    do
      # start out adding AK to KA to get the total "AK" hands
      # but if both cards are equal, do incorrectly double the PP
      SITE_STAT_HOLE_CARD_COUNT_SQL="SELECT cards_$FIRST_CARD$SECOND_CARD + cards_$SECOND_CARD$FIRST_CARD FROM site_hands WHERE statistic = '$SQL_STAT'"
      if [[ "$FIRST_CARD" == "$SECOND_CARD" ]]; then
        SITE_STAT_HOLE_CARD_COUNT_SQL="SELECT cards_$FIRST_CARD$SECOND_CARD FROM site_hands WHERE statistic = '$SQL_STAT'"
      fi

      SITE_STAT_HOLE_CARD_COUNT=`executeSQL "$SITE_STAT_HOLE_CARD_COUNT_SQL"`
      SITE_STAT_HOLE_CARD_COUNT_PCT=$(bc <<< "scale=4; x = $SITE_STAT_HOLE_CARD_COUNT / $TOTAL_HANDS_DEALT * 100; scale = 2; x / 1")

      # see if this is the most common hand so far
      if [[ $SITE_STAT_HOLE_CARD_COUNT -gt $MOST_COMMON_HAND_COUNT ]]; then
        MOST_COMMON_HAND_COUNT=$SITE_STAT_HOLE_CARD_COUNT
      fi

      # see if this is the least common hand so far
      if [[ $SITE_STAT_HOLE_CARD_COUNT -lt $LEAST_COMMON_HAND_COUNT ]]; then
        LEAST_COMMON_HAND_COUNT=$SITE_STAT_HOLE_CARD_COUNT
      fi

      # format the numbers
      SITE_STAT_HOLE_CARD_COUNT=$(printf "%'d" $SITE_STAT_HOLE_CARD_COUNT)
      SITE_STAT_HOLE_CARD_COUNT_PCT=$(printf "%.2f" $SITE_STAT_HOLE_CARD_COUNT_PCT)

      ROW_ALL_TDS="$ROW_ALL_TDS <td class=\"playerstats-cell\">$SITE_STAT_HOLE_CARD_COUNT<br/>($SITE_STAT_HOLE_CARD_COUNT_PCT%)</td>"

    done
    ROW_TR="${ROW_TR//_SITE_STAT_TD_/$ROW_ALL_TDS}"    
    SITE_STAT_ALL_TRS="$SITE_STAT_ALL_TRS $ROW_TR"
  done

  # find least and most common hands and replace their HTML so they are colored and  old
  SITE_STAT_ALL_TRS="${SITE_STAT_ALL_TRS//\">$(printf "%'d" $LEAST_COMMON_HAND_COUNT)<br/ \" style=\"color\: red\; font-weight\: bold\;\">$(printf "%'d" $LEAST_COMMON_HAND_COUNT)<br}"
  SITE_STAT_ALL_TRS="${SITE_STAT_ALL_TRS//\">$(printf "%'d" $MOST_COMMON_HAND_COUNT)<br/ \" style=\"color\: green\; font-weight\: bold\;\">$(printf "%'d" $MOST_COMMON_HAND_COUNT)<br}"

  SITE_STAT_HOLE_CARDS_DATA="${SITE_HOLE_CARDS_STAT_TEMPLATE//_SITE_HOLE_CARD_STAT_DATA_/$SITE_STAT_ALL_TRS}"
  ALL_STATS_BODY="$ALL_STATS_BODY $SITE_STAT_HOLE_CARDS_DATA"
done

# close last div on the navigation pills
STAT_NAV_BODY="$STAT_NAV_BODY </div>"

HTML_CONTENT=$(awk -v r="$STAT_NAV_BODY" '{gsub(/_STAT_NAVIGATION_/,r)}1' templates/site-hands.html)
HTML_CONTENT="${HTML_CONTENT//_SITE_STAT_CARD_BODY_/$ALL_STATS_BODY}"

# replace poker site name
HTML_CONTENT="${HTML_CONTENT//_POKER_SITE_NAME_/$POKER_SITE_NAME}"

# add generation date
HTML_CONTENT="${HTML_CONTENT//_GENERATED_ON_/$DATE}"
HTML_CONTENT=`tidy -indent --indent-spaces 2 -quiet --tidy-mark no -w 200 --vertical-space no <<< $HTML_CONTENT`
# print it to the file
echo "$HTML_CONTENT" > web/site-cards.html
