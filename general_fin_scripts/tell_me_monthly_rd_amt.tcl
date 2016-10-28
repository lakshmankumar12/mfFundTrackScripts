#!/usr/bin/tclsh

puts -nonewline "Enter the corput you want:"; flush stdout;
gets stdin exp_corpus  
if { [ string is space $exp_corpus ] == 1 } { 
  puts "You must enter an amount" ; exit
} elseif { [ string is integer $exp_corpus ] == 0 } {
  puts "You should enter integral value" ; exit
} elseif { $exp_corpus <= 0 || $exp_corpus > 1000000000 } {
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

proc fd_return { amt monthly_rr tot_months } {
  set corpus 0
  for { set i 1 } { $i <= $tot_months } { incr i } {
    set corpus [ expr $corpus + $amt ] 
    set corpus [ expr $corpus * $monthly_rr ] 
  }
  return $corpus
}

proc middle { upper lower } {
  return [ expr ( $upper + $lower ) / 2.0 ]
}

set tot_months [ expr $yr * 12 ]
set monthly_rr [ expr "1.0 + ( $rr / 1200.0 )" ]

;# Take a guess and converge.
;#   $upper =  $exp_corpus / $tot_months
;#     (which will obviously be greater)
;#   $lower = 1
;#     (which is obviously less)
;#   $guess =  middle ($upper, $lower)
;# If ( $guess is insufficient) {
;#   $lower = $guess. compute new $guess and try
;# ElseIf ( $guess is high) {
;#   $upper = $guess. compute new $guess and try
;# Error when ($upper - $lower == 1)
set upper [ expr ($exp_corpus * 1.0 )/ $tot_months ]
set lower 1.0

if { $upper < $lower } {
  puts "Huh! Impossible corpus. Current upper:$upper, lower: $lower"
  exit 1;
}

set i 1
while {1} {
  set guess  [ middle $upper $lower ] 
  if { ($upper - $lower) < 1.0 } {
    ;# we have converged
    break;
  }
  set guess  [ middle $upper $lower ] 
  set corpus [ fd_return $guess $monthly_rr $tot_months ] 
  if { $corpus < $exp_corpus } {
    set lower $guess
  } elseif { $corpus > $exp_corpus } {
    set upper $guess
  }
  ;#puts "$i, upper: $upper lower: $lower guess: $guess"
  incr i
}

puts ""
puts "Corups wanted:    $exp_corpus"
puts "Yearly rate:      $rr, monthly rr:$monthly_rr"
puts "No of years:      $yr, tot_months:$tot_months"
puts "Amount per mth:   $guess"
