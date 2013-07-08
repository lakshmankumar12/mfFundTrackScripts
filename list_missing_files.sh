#!/bin/bash

REPODIR=repo

cd $REPODIR

for yyyy in $(seq 2006 2012) ; do
  for mm in $(seq -w 01 12) ; do 
    month="$yyyy-$mm"
    days=$(cal $mm $yyyy | tail -n +3 | awk -v mm=$mm -v yyyy=$yyyy ' { 
        for (i=1;i<=NF;i++) { 
          printf "%d-%02d-%02d\n",yyyy,mm,$i 
        } 
      } ')
    if [ ! -f $month-nav.tar.bz2 ] ; then
      for i in $days ; do 
        echo "$i not found";
      done
      continue;
    fi
    for i in $days ; do echo $i ; done | awk -v tarfile="$month-nav.tar.bz2" ' BEGIN {
      cmd = "tar jtf " tarfile;
      while ( cmd | getline ) {
        files_in_tar[$0] = 1;
      }
    } 
    1 {
      if ( files_in_tar[$0 "-nav"] != 1 ) {
        print $0 " not found";
      } else {
        print $0 " exists";
      }
    }'
  done
done
