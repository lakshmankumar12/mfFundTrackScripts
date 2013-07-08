#!/bin/bash

if [ -z $1 ] ; then
  echo "give the src file name"
  exit 1
fi

if [ ! -f $1 ] ; then
  echo "$1 isn't readable"
  exit 1
fi

date=${1:0:11}
tgt="${date}nav"

awk -F\; '
/Scheme Name/ {
  next;
}
/;/ {
  print $4 ";" $5 ";"
}' $1 > $tgt
