import argparse
import glob
import re
import platform

# converts a cygwin/ming style path to windows for windows python
def convert_path_to_windows(path):
    match = re.match('(/(cygdrive/)?)(.*)', path)
    if not match:
        return path.replace('/', '\\')
    dirs = match.group(3).split('/')
    dirs[0] = f'{dirs[0].upper()}:'
    return '\\'.join(dirs)

# args
#  - player
#  - file pattern to scan

parser = argparse.ArgumentParser(description='Calculate hands played for a player')
parser.add_argument('--player', dest='player', action='store', required='true', help='the player account name')
parser.add_argument('--pattern', dest='pattern', action='store', required='true', help='the file glob pattern')
args = parser.parse_args()

filePattern = args.pattern
if platform.system() == "Windows":
	filePattern = convert_path_to_windows(filePattern)
	print(filePattern)

handsPlayed = 0
regex = r"Hand #(.|\n)*?(?:{player} (?:calls|checks|raises|bets))(?:.|\n*^\s*$)".format(player=args.player)
for filename in glob.iglob(filePattern):
	file = open(filename, mode='r', encoding="utf8")
	handHistory = file.read()
	file.close()

	# very important to skip large files that don't include at least 1 matches
	# since there is a huge performance pentalty for this regex on a file without
	# any matches at all
	if not re.search(args.player, handHistory):
		# print("Skipping " + filename)
		continue

	matches = re.findall(regex, handHistory, re.MULTILINE)
	if matches is not None:
		handsPlayed += len(matches)

	# print(filename + ": " + str(len(matches)))

# only print total hands played
print(handsPlayed)
