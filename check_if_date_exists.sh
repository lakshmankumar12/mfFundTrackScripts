#!/bin/bash

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
