#!/bin/sh

gnuplot -persist <<EOF
plot '$1' index 0 title '$(basename $1)' with points,         \
     '$1' index 1 title 'Mean' with lines,                    \
     '$1' index 2:3 title 'One standard deviation' with lines
EOF
