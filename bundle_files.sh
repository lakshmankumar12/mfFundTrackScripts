#!/bin/bash

REPODIR=../nav-repo/

cd $REPODIR

for i in $(seq 2006 2014) ; do
  for j in $(seq -w 01 12) ; do 
    month="$i-$j"
    list="$month*nav"
    if stat -t $list >/dev/null 2>&1
    then
        echo "found for $month: "
        ls ${month}*nav
        if [ -f $month-nav.tar.bz2 ] ; then
          bunzip2 $month-nav.tar.bz2
        fi
        tar uvf $month-nav.tar $month*nav
        bzip2 $month-nav.tar
        rm ${month}*nav
    else 
        echo "Nothing for month:$month"
    fi
  done
done
