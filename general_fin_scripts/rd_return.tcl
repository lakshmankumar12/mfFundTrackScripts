#!/usr/bin/tclsh

puts -nonewline "Enter the amount you put every month:"; flush stdout;
gets stdin amt  
if { [ string is space $amt ] == 1 } { 
  puts "You must enter an amount" ; exit
} elseif { [ string is integer $amt ] == 0 } {
  puts "You should enter integral value" ; exit
} elseif { $amt <= 0 || $amt > 10000000 } {
  puts "allowed range (1-10000000)"; exit
}

puts -nonewline "Enter the rate of return(8):"; flush stdout;
gets stdin rr
if { [ string is space $rr ] == 1 } { 
  set rr 8.0
} elseif { [ string is double $rr ] == 0 } {
  puts "You should enter numberical value" ; exit
} elseif { $rr < 0 || $rr > 25 } {
  puts "allowed range (0-25)"; exit
}

puts -nonewline "Enter the number of years(30):"; flush stdout;
gets stdin yr
if { [ string is space $yr ] == 1 } { 
  set yr 30
} elseif { [ string is integer $yr ] == 0 } {
  puts "You should enter integral value" ; exit
} elseif { $yr <= 0 || $yr > 100  } {
  puts "allowed range (1-100)"; exit
}

set tot_months [ expr $yr * 12 ]
set monthly_rr [ expr "1.0 + ( $rr / 1200.0 )" ]

set corpus 0
for { set i 1 } { $i <= $tot_months } { incr i } {
  set corpus [ expr $corpus + $amt ] 
  set corpus [ expr $corpus * $monthly_rr ] 
}

puts ""
puts "Amount per month: $amt"
puts "Yearly rate:      $rr, monthly rr:$monthly_rr"
puts "No of years:      $yr, tot_months:$tot_months"
puts "Corpus:           $corpus"
