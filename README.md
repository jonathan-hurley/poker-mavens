# Poker Mavens Assets & Supporting Files
This repository contains asset files for Poker Mavens v6.x

## Graphs
The scripts located in `scripts/graphs` are used to generate graphs which show the stack sizes of players during a tournament.
- `generate-graphs.sh` is the top level script which can be run. It relies on the following tools:
  - `gnuplot`
  - `grep`/`egrep`/`pcregrep`
- `players.sh` is used to list all players which should be processed
- `generatePlotData.sh` reads in starting stack sizes from Poker Mavens and generates temporary files formatted for `gnuplot` with stack size data
- `*.plot` files are used by `gnuplot` to generate SVGs

A `web` directory is present with `js/gnuplot` which is needed by the interactive SVGs that `gnuplot` creates. If you are not creating interactive plots and only static SVGs, then you don't need those JavaScript files.

Some of this code is still tightly coupled to the author's games. Names of games, file locations, etc, will need to be modified.
