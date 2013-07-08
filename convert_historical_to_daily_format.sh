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

awk '
BEGIN {
  lastline=""
}
/([[:digit:]]+\.[[:digit:]]+[[:space:]]+){3}/ {
  gsub("^[[:space:]]*","",lastline);
  gsub("[[:space:]]$","",lastline);
  fund=lastline;
  nav=$1;
  print fund ";" nav ";"
  next
}
1 {
  lastline=$0
}' $1 > $tgt
