#!/usr/bin/env bash
. scripts/sync-database.sh
. scripts/generate-stats.sh
. scripts/generate-winnings.sh
. scripts/generate-buy-ins.sh
. scripts/generate-player-hands.sh
. scripts/generate-site-hands.sh

. scripts/finalize.sh