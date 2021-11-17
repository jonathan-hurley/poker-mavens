# cleanup time
echo ""
echo "=========   FINALIZING   ========="
echo "Cleaning up the following temporary directories:"
if [ -d "$ALL_HANDS_SYNC_TEMP_DIR" ]; then echo "  → $ALL_HANDS_SYNC_TEMP_DIR"; rm -Rf $ALL_HANDS_SYNC_TEMP_DIR; fi
if [ -d "$TOURNMANENT_TEMP_DIR" ]; then echo "  → $TOURNMANENT_TEMP_DIR"; rm -Rf $TOURNMANENT_TEMP_DIR; fi
if [ -d "$CASH_TEMP_DIR" ]; then echo "  → $CASH_TEMP_DIR"; rm -Rf $CASH_TEMP_DIR; fi
if [ -d "$HOLDEM_TEMP_DIR" ]; then echo "  → $HOLDEM_TEMP_DIR"; rm -R $HOLDEM_TEMP_DIR; fi
if [ -d "$OMAHA_TEMP_DIR" ]; then echo "  → $OMAHA_TEMP_DIR"; rm -R $OMAHA_TEMP_DIR; fi
if [ -d "$LOG_TEMP_DIR" ]; then echo "  → $LOG_TEMP_DIR"; rm -R $LOG_TEMP_DIR; fi
if [ -d "$TOURNEY_RESULTS_TEMP_DIR" ]; then echo "  → $TOURNEY_RESULTS_TEMP_DIR"; rm -R $TOURNEY_RESULTS_TEMP_DIR; fi
echo ""