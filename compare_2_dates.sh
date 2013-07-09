#!/bin/bash

SCRATCH_DIR=../nav-repo/scratch

date1=$1
date2=$2

./get_common_funds.sh -i ../nav-repo/scratch/$date1-nav ../nav-repo/scratch/$date2-nav > $date1-vs-$date2-inter
./check_returns.tcl $date1 $date2 $date1-vs-$date2-inter > $date1-vs-$date2-result
sort -t\; -k 4 -r -n $date1-vs-$date2-result > $date1-vs-$date2-sort

