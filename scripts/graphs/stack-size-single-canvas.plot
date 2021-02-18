#!/usr/bin/env gnuplot -c

################################################################################
# Generates a single, interactive graph of the CSV file provided as an argument
################################################################################

# Show usage information if no argument is present
if (strlen(ARG1) == 0 || strlen(ARG2) == 0) print "Usage: " . ARG0 . " lockdown.csv Lockdown"; exit

# Output W3C Scalable Vector Graphics
set terminal canvas jsdir "js/gnuplot" enhanced mouse size 1080, 1080

set timestamp "Generated on %B %d, %Y at %H:%M" font "Helvetica"

set title ARG2 . " Tournament Stack Size" font ",20"

# Read comma-delimited data from file
set datafile separator comma

# Set label of x-axis
set xlabel 'Time/Hands'

# Set label of y-axis
set ylabel 'Stack Size'

# Use a line graph
set style data line

set key autotitle columnheader left

set mouse mouseformat "mouse x,y = %d, %df"
set mouse format "%d"

plot for [i=0:*] ARG1 using 0:1 index i linewidth 2
