#!/usr/bin/env gnuplot -c

# Generates a combined, non-interactive graph of the CSV files provided as arguments

# Show usage information if no argument is present
if (strlen(ARG1) == 0 || strlen(ARG2) == 0) print "Usage: " . ARG0 . " lockdown.csv smackdown.csv"; exit

# Output W3C Scalable Vector Graphics
set terminal svg enhanced mouse size 1080, 1080

set multiplot layout 2, 1 title "Tournament Stack Size" font "Arial,30"
set tmargin 4

set timestamp "Generated on %B %d, %Y at %H:%M" font "Helvetica"

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

set title "Lockdown (Friday)" font ",20"
plot for [i=0:*] ARG1 using 0:1 index i linewidth 2

set title "Smackdown (Sunday)" font ",20"
plot for [i=0:*] ARG2 using 0:1 index i linewidth 2
