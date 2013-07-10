#!/bin/bash

if [ -z "$1" ] ; then
  echo "Usage: $0 <no-of-dates-to-download>"
fi

count=$1

current_file="current_file"
pending_file="pending_file"

echo "starting $count tasks at"
date

if [ -f $current_file ] ; then
  echo "A task was stopped midway!"
  cat $current_file
  exit 1
fi

remaining_lines=$(cat $pending_file | wc -l)
echo "remaining_lines:$remaining_lines"
while [ $remaining_lines -gt 0 -a $count -gt 0 ] ; do
  tail -n 1 $pending_file > $current_file
  head -n -1 $pending_file > temp.$$ ; mv temp.$$ $pending_file
  a=$(cat $current_file);
  echo "Performing $a"
  export TERM=xterm
  ./get_hist_nav_for_a_date.tcl $(cat $current_file)
  if [ $? -ne 0 ] ; then
    cat $current_file >> $pending_file
    rm $current_file
    exit 1
  fi
  rm $current_file
  remaining_lines=$(cat $pending_file | wc -l)
  ./convert_historical_to_daily_format.sh "$a-hist"
  rm "$a-hist"
  count=$(expr $count - 1)
done


