#!/usr/bin/expect

set input_date_pattern {([[:digit:]]{4})-([[:digit:]]{2})-([[:digit:]]{2})}

proc usage {} {
  global argv0
  puts "usage:"
  puts "$argv0 <yyyy-mm-dd>"
  exit 1
}

proc handle_time_out { exit_option err_log } {
  global link
  global started_getting
  puts "Timed out: $err_log"
  puts "link: $link"
  if { $exit_option == 0 } {
    if { $started_getting != 1 } { 
      exit 1
    }
    if { $::env(NO_INTERACT) == 1 } {
      exit 1;
    }
    interact
  }
  exit 1
}

if { $argc != 1 } { 
  usage
}

set date [ lindex $argv 0 ]
if { [ regexp $input_date_pattern $date discard yyyy mm dd ] != 1 } {
  puts "$date didn't match pattern:$input_date_pattern"
  usage
}
set epoch [ clock scan "$yyyy-$mm-$dd 00:00:00" -gmt 1 ]
set link_date [ clock format $epoch -format {%Y-%b-%d} -gmt 1 ]

set link "http://www.amfiindia.com/NavHistoryReport_Rpt_Po.aspx?rpt=0&frmdate="
append link $link_date

puts "link: $link"

set started_getting 0

spawn w3m $link

set page_op ""

set timeout 20

expect {
  "Received cookie:"         { set started_getting 1 ; exp_continue }
  "||"                       { exp_continue }
  "May lead to memory leak and poor performance" { exp_continue }
  full_buffer                { exp_continue }
  timeout                    { handle_time_out 0 "nav-history timed out" }
  "Viewing <NAV - History>"
}

send "S"

expect {
  timeout                    { handle_time_out 1 "save history" }
  "Save buffer to: "          
}

set filename "$date-hist"

send "$filename\r"

expect {
  timeout                    { handle_time_out 1 "saving file timed out" }
  "Viewing <NAV - History>"
}

send "qy"
expect eof

puts "link: $link saved to $filename"
