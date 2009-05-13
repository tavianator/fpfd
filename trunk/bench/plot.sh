#!/bin/sh

prefix=$(dirname $1 | sed 's|.*/\(.*\)|\1|g' | tr '[:lower:]' '[:upper:]');
suffix=$(basename $1 .dat)

if [ "$2" = "png" ]; then
  gnuplot <<EOF
set lmargin 6
set rmargin 4
set term png size 665,480 enhanced
set output '${prefix}_$suffix.png'
plot '$1' index 0 title '$prefix $suffix' with points,        \
     '$1' index 1 title 'Mean' with lines,                    \
     '$1' index 2:3 title 'One standard deviation' with lines
EOF
else
  gnuplot -persist <<EOF
set lmargin 6
set rmargin 4
plot '$1' index 0 title '$prefix $suffix' with points,        \
     '$1' index 1 title 'Mean' with lines,                    \
     '$1' index 2:3 title 'One standard deviation' with lines
EOF
fi
