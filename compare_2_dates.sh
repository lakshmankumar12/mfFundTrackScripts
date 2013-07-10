#!/bin/bash

usage()
{
  echo "Usage: $0 <beg-date> <end-date>"
  exit 1;
}

if [ $# -ne 2 ] ; then 
  usage
fi

REPO_DIR=../nav-repo
SCRATCH_DIR=../nav-repo/scratch
MASTER_LIST=../nav-repo/master_list
RESULT_DIR=./analysis-results

date1=$1
date2=$2

check_if_date_exists()
{
  date_exists=0
  date=$1
  date_file=$date-nav

  if [ -f $SCRATCH_DIR/$date_file ] ; then
   echo "good .. file for $date exists in scratch dir already!"
   date_exists=1;
  else 
   month=${date:0:7}
   month_file=$month-nav.tar.bz2
   if [ -f $REPO_DIR/$month_file ] ; then 
     date_present=$(tar jtf $REPO_DIR/$month_file $date_file  | grep $date | wc -l)
     if [ $date_present == 1 ] ; then 
        echo "good .. $date exists in tarball"
        tar jxf $REPO_DIR/$month_file $date_file
        mv $date_file $SCRATCH_DIR
        date_exists=1;
     fi
   fi
  fi

  if [ $date_exists -eq 0 ] ; then 
    echo "getting $date file"
    ./get_hist_nav_for_a_date.tcl $date
    if [ $? -ne 0 ] ; then
      exit 1
    fi
    ./convert_historical_to_daily_format.sh "$date-hist"
    rm "$date-hist"
    mv $date-nav $SCRATCH_DIR
  fi
}
    

check_if_date_exists $date1
check_if_date_exists $date2
 
COMMON_BASE=$date1-vs-$date2

INTERSECT_SUFFIX=intersect
CAGR_SUFFIX=cagr
CAGR_SORT_SUFFIX=cagr_sort
CAGR_SORT_TYPES_SUFFIX=cagr_sort_types
TYPES_SORT_SUFFIX=types_sort
ERRORS_SUFFIX=errors

mkdir -p $RESULT_DIR/$COMMON_BASE
COMMON_BASE=$RESULT_DIR/$COMMON_BASE

./get_common_funds.sh -i $SCRATCH_DIR/$date1-nav $SCRATCH_DIR/$date2-nav > $COMMON_BASE/$INTERSECT_SUFFIX
./check_returns.tcl $date1 $date2 $COMMON_BASE/$INTERSECT_SUFFIX > $COMMON_BASE/$CAGR_SUFFIX 2> $COMMON_BASE/$ERRORS_SUFFIX
sort -t\; -k 4 -r -n $COMMON_BASE/$CAGR_SUFFIX > $COMMON_BASE/$CAGR_SORT_SUFFIX
./assign_types_to_funds.sh $MASTER_LIST $COMMON_BASE/$CAGR_SORT_SUFFIX > $COMMON_BASE/$CAGR_SORT_TYPES_SUFFIX
sort -t\| -k 5,5 -s $COMMON_BASE/$CAGR_SORT_TYPES_SUFFIX > $COMMON_BASE/$TYPES_SORT_SUFFIX
