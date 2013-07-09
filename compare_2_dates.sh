#!/bin/bash

usage()
{
  echo "Usage: $0 <beg-date> <end-date>"
  exit 1;
}

if [ $# -ne 2 ] ; then 
  usage
fi

SCRATCH_DIR=../nav-repo/scratch
MASTER_LIST=../nav-repo/master_list

date1=$1
date2=$2

COMMON_BASE=$date1-vs-$date2

INTERSECT_SUFFIX=intersect
CAGR_SUFFIX=cagr
CAGR_SORT_SUFFIX=cagr_sort
CAGR_SORT_TYPES_SUFFIX=cagr_sort_types
TYPES_SORT_SUFFIX=types_sort
ERRORS_SUFFIX=errors

./get_common_funds.sh -i ../nav-repo/scratch/$date1-nav ../nav-repo/scratch/$date2-nav > $COMMON_BASE-$INTERSECT_SUFFIX
./check_returns.tcl $date1 $date2 $COMMON_BASE-$INTERSECT_SUFFIX > $COMMON_BASE-$CAGR_SUFFIX 2> $COMMON_BASE-$ERRORS_SUFFIX
sort -t\; -k 4 -r -n $COMMON_BASE-$CAGR_SUFFIX > $COMMON_BASE-$CAGR_SORT_SUFFIX
./assign_types_to_funds.sh $MASTER_LIST $COMMON_BASE-$CAGR_SORT_SUFFIX > $COMMON_BASE-$CAGR_SORT_TYPES_SUFFIX
sort -t\| -k 5,5 -s $COMMON_BASE-$CAGR_SORT_TYPES_SUFFIX > $COMMON_BASE-$TYPES_SORT_SUFFIX
