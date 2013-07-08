#!/usr/bin/tclsh

set date_pattern {([[:digit:]]{4})-([[:digit:]]{2})-([[:digit:]]{2})}

source ./compute_cagr.tcl

proc usage { } {
  global argv0
  puts "usage:"
  puts "$argv0 <start-dd-mm-yyyy> <start-nav> <end-dd-mm-yyyy> <end-nav>"
  exit 1
}

if { $argc != 4 } {
  usage
}

set st_date  [ lindex $argv 0 ]
set st_nav   [ lindex $argv 1 ]
set end_date [ lindex $argv 2 ]
set end_nav  [ lindex $argv 3 ]

set res [ regexp $date_pattern $st_date discard st_yyyy st_mm st_dd ]
if { $res != 1 } {
  puts "start date: $st_date is not in dd-mm-yyyy format" ; usage
}

set res [ regexp $date_pattern $end_date discard end_yyyy end_mm end_dd ]
if { $res != 1 } {
  puts "end date: $end_date is not in dd-mm-yyyy format" ; usage
}


set start_epoch [ get_epoch $st_dd $st_mm $st_yyyy ]
set end_epoch   [ get_epoch $end_dd $end_mm $end_yyyy ]
set days [ get_difference_in_days_from_epoch $start_epoch $end_epoch ]

set cagr [ expr [ get_cagr $st_nav $end_nav $days ] * 100 ]

puts "$cagr"
