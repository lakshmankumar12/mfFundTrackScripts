#!/usr/bin/tclsh

set date_pattern {([[:digit:]]{4})-([[:digit:]]{2})-([[:digit:]]{2})}

source ./compute_cagr.tcl

proc usage { } {
  global argv0
  puts "usage:"
  puts "$argv0 <start-dd-mm-yyyy> <end-dd-mm-yyyy> <file>"
  exit 1
}

if { $argc != 3 } {
  usage
}

set st_date  [ lindex $argv 0 ]
set end_date [ lindex $argv 1 ]
set nav_file [ lindex $argv 2 ]

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

if { [ string compare $nav_file "-" ] == 0 } {
  set nav_file stdin
}

set fp [ open $nav_file "r" ]

while { [gets $fp data] >= 0 } {
  set data [ string trim $data ]
  if { [ string length $data ] == 0 } { continue }
  set values [ split $data ";" ]
  set fund [ lindex $values 0]
  set beg_nav [ lindex $values 1]
  set end_nav [ lindex $values 2]
  if { [ catch { set cagr [ expr [ get_cagr $beg_nav $end_nav $days ] * 100 ] } value ] } {
    puts stderr "calculating cagr failed for fund $fund, beg_nav: $beg_nav, end_nav: $end_nav, message: $value"
  }
  puts "$fund;$beg_nav;$end_nav;$cagr"
}
close $fp

