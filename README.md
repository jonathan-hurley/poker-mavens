# Poker Mavens Assets & Supporting Files
This repository contains scripts and asset files for Poker Mavens v6.x. The following is an abbreviate list of what kinds of statistics are calculate:
- Site-wide statistics such as total number of hands, types of hands, winning hands, pocket pairs, etc
- Player statistics such as the total winnings, profits, dealt hands, etc


## Prerequisites
### Logs
Although a lot of this works off of the Tournament Results and Hand History logs, a lot of the cash game code requires the regular logs as well. You'll want to configure your Poker Mavens server to retain all logs and never get rid of them. Under the `System` tab, you'll want to make sure that the following settings are configured:
- `Save Logs to File`: `Yes`
- `Maximum Log Days`: `0`
- `Maximum History Days`: `0`
- `Maximum Tournament Days`: `0`

### Required Software
You can see the list of software in the next section entitled "Getting Started". Although there are many ways to run the scripts locally on a fast computer, much of this guide was written assuming that you will want to run this on an Amazon EC2 instance that is hosting your Poker Mavens site.

### Hosting the Web Pages
As this guide has been written assuming minimal knowledge and capabilities of the user, it's also designed to have Poker Mavens host the HTML files itself. 

The scripts below will create static HTML pages that you can have Poker Mavens host. There's a configuration under `System` -> `Web Settings` -> `Web Folder`. This can point directly to the folder in this repository called `web`. 

## Getting Started
Depending on which operating system you are using, you may need to download one or more of the following supporting files. 
- `bash`
- `sed`
- `grep` / `egrep`
- `bc`
- `printf`
- `python`
- `git`
- `tidy`

### Linux & MacOS
Both Linux and MacOS should ship with the necessary CLI tools already. If running on MacOS, you can always use [brew](https://brew.sh/) to install the necessary dependencies

### Windows
Some users, especially those want to run this directly on their AWS EC2 instance, may be running on Windows. The scripts are compatible with [Git Bash](https://gitforwindows.org) and many of the required commands are already included with it. But there are steps needed to download the other commands which are not included.

1. After installing Git, you can now clone the repository. Open up the `Git Bash` program from your Start Menu and create a simple directory to clone into:
    ```
    $ mkdir -p /c/poker-maven-tools && cd /c/poker-maven-tools
    $ git clone https://github.com/jonathan-hurley/poker-mavens.git .
    ```

2. You will need to download Windows versions of `bc`, `python`, and `tidy`. Althought `python` should be automatically added to your path, the other two will not be. The scripts try to automatically add them, but you should still add them to your path so they can be executed from `Git Bash`.
   - [`bc`](http://gnuwin32.sourceforge.net/packages/bc.htm): download the Windows installer and run it in order to install `bc`.
   - [`python`](https://www.python.org/downloads/windows/): download the latest v3 Python release for Windows and install it.
   - [`tidy`](http://binaries.html-tidy.org/): download the the latest version of `tidy` (as of this writing it was [`tidy-5.8.0-win64.exe`](https://github.com/htacg/tidy-html5/releases/download/5.8.0/tidy-5.8.0-win64.exe))

3. You can choose to modify the following files to better customize your results:
     - `images/logo.png`: this is the logo that is generated at the top of all HTML files
     - `scripts/config.sh`: specifically, the `POKER_SITE_NAME` environment variable

## Running the Scripts
You should be able to the run the scripts using `Git Bash` and executing the `generate.sh` script.
```
$ ./scripts/generate.sh 
```

Output files are placed in the `web` folder:
- `web/stats.html`: site and player hand statistics
- `web/winnings-results.html`: total player profits/winnings between cash and tournament
- `web/player-cards.html` (optional): the script for this is disabled by default because of how long it takes, but this represents all hole card combinations dealt to a player.


## Directory Structure
The following is a brief explanation of the directory structure of this repository.

### Scripts (`./scripts`)
The shell scripts located in `scripts` are used to generate static HTML pages that contain site and player hand statistics. Although they were written for MacOS/Linux, they do work under both `Git Bash` and `Cygwin`.

- `config.sh`: environment variables for path locations, custom text, etc
- `common.sh`: functions that are reused across other script files for calculations and parsing
- `generate-buy-ins.sh`: determines how much a player has spent on tournament buy-ins
- `generate-player-hands.sh`: creates a 13x13 matrix of every pocket hole card combination for each player and tallies the number of times they have received it. This is a very intensive script and takes a long time to run.
  - outputs: `web/player-cards.html`
- `generate-stats.sh`: builds the site and player statistics as well as profits and loss
  - outputs: `web/stats.html`
- `generate-winnings.sh`: builds both the cash and tournament profits/winnings
  - outputs: `web/winnings-results.html`
- `generate.sh`: top level script that runs others
  - outputs:
    - `web/stats.html`
    - `web/winnings-results.html`
- `hands-played.py`: calculates how many hands a player was dealt, folded, played, etc
- `players.sh`: a list of the players to run the program for as well as any offsets to calculate into their totals

### Templates (`./templates`)
The HTML files located in `templates` are used as template files when rendering the static HTML pages.

### Web (`./web`)
All supporting HTML files are stored in the `web` directory. These include supporting JavaScript, CSS, images and fonts for any static HTML pages created from the scripts.

### Assets (`./assets`)
The files in `assets` are icons, cards, tables, etc that are for customizing the look of Poker Mavens. 

### 3D Models (`./models`)
The files in `models` are poker related 3D models that I had nowhere else to put and didn't feel like making a new repository.

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
