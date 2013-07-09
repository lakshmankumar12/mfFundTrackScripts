#!/bin/bash

usage()
{
  echo "Usage: $0 <master-list> <result-of-compare>"
  exit 1;
}

if [ $# -ne 2 ] ; then 
  usage
fi

master_list=$1
sorted_cagr_file=$2

awk -v master_list=$master_list ' BEGIN { 
    FS=";" ;
    while ( getline < master_list ) {
      master_list_funds[$1]=1;
      master_list_type[$1]=$3;
      master_list_company[$1]=$4;
    }
  }
  1 {
    fund=$1;
    format_string="%-100s | %20s | %20s | %20.3f | %-40s |\n"
    if (fund in master_list_funds) {
      printf format_string,$1,$2,$3,strtonum($4),master_list_type[fund]
    } else {
      printf format_string,$1,$2,$3,strtonum($4),"unknown_type"
    }
  }' $sorted_cagr_file
