#!/usr/bin/tclsh

proc get_epoch { dd mm yyyy } {
  set epoch [ clock scan "$yyyy-$mm-$dd 00:00:00" -gmt 1 ]
  return $epoch
}

proc get_date { epoch dd_arg mm_arg yyyy_arg } {
  upvar $dd_arg dd
  upvar $mm_arg mm
  upvar $yyyy_arg yyyy
  set date [ clock format $epoch -format {%Y %m %d} -gmt 1 ]
  set yyyy [ lindex $date 0]
  set mm   [ lindex $date 1]
  set dd   [ lindex $date 2]
  return "$dd-$mm-$yyyy"
}

proc get_difference_in_days_from_epoch { epoch_old epoch_new } {
  set diff [ expr $epoch_new - $epoch_old ] 
  set days [ expr ( $diff + 1 ) / 86400 ]
  return $days
}

proc get_difference_in_days { old_dd old_mm old_yyyy new_dd new_mm new_yyyy } {
  set old_epoch [ get_epoch $old_dd $old_mm $old_yyyy ]
  set new_epoch [ get_epoch $new_dd $new_mm $new_yyyy ]
  return [ get_difference_in_days_from_epoch $old_epoch $new_epoch ] 
}

proc get_compounded_return { inv rate period } {
  set one_plus_rate [ expr 1 + $rate ]
  set growth [ expr pow($one_plus_rate,$period) ]
  return [ expr $inv * $growth ]
}

proc get_avg { val1 val2 } {
  return [ expr ( $val1 + $val2 ) / 2.0 ]
}

proc get_cagr { inv returns days } {

  if { $returns == $inv } {
    return 0;
  }

  ;# lets start with a guess.
  set max_attempts 100
  set attempt 1
  set initial_guess 0.05
  set step          0.05
  set accuracy_factor 0.0001

  set period [ expr $days / 365.0 ]

  ;# We start with guess. If returns are not withing acceptible limits,
  ;#   we increase/decrease our guess by step value until we mark a
  ;#     lower-limit and upper-limit.
  ;#   Once we have marked a lower and upper, the new guess is the 
  ;#     average of the current lower and upper. Then after we 
  ;#     check this new guess, we either make it the next lower/upper
  ;#     and converge.

  set guess $initial_guess

  while { $attempt <= $max_attempts } {
    set result_returns [ get_compounded_return $inv $guess $period ]
    ;#set debug 1
    if { [ info exists debug ] } {
      if { [ info exists lower_limit ] } {
        set ll [ format %4.4lf $lower_limit ]
      } else {
        set ll "ll-ns"
      }
      if { [ info exists upper_limit ] } {
        set ul [ format %4.4lf $upper_limit ]
      } else {
        set ul "ul-ns"
      }
      puts [ format "%d %4.4f (%s %s) %f %f" $attempt $guess $ll $ul $result_returns $returns ]
    }
    if { abs($result_returns - $returns) <= $accuracy_factor } {
      ;# wow!
      return $guess
    }
    if { [ info exists lower_limit ] &&
         [ info exists upper_limit ] } {
      ;# we have alrady marked
      if { $result_returns < $returns } {
        set lower_limit $guess
      } else {
        set upper_limit $guess
      }
      set guess [ get_avg $lower_limit $upper_limit]
    } else {
      ;# we are yet to either atleast one limit
      if { $result_returns < $returns } {
        set lower_limit $guess
        set guess [ expr $guess + $step ]
      } else {
        set upper_limit $guess
        set guess [ expr $guess - $step ]
      }
    }
    incr attempt
  }

  puts "Ran out of attempts"
  exit 1
}

;# input(no_of_items)  - should tell number of samples. Must be minimally 2.
;# input(value,0)      - initial investment or borrowing
;# input(value,1)      - second investment or borrowing
;# input(normalized_date,1)       - no of days since this second investment happened from first.
;# ...
;# input(normalized_date,$no_of_items-1) -  no of days of the last transaction from the first transaction. This should be >=365.
proc get_xirr_core { input_arg } {

  upvar $input_arg input

  ;#set debug 1

  if { [ info exists debug ]  } {
    parray input
  }

  set max_attempts 100
  set attempt 1
  set initial_guess 0.05
  set step          0.02
  set accuracy_factor 0.0001

  ;# We start with guess. If sum is not within acceptible limits,
  ;#   we increase/decrease our guess by step value until we mark a
  ;#     lower-limit and upper-limit.
  ;#   Once we have marked a lower and upper, the new guess is the 
  ;#     average of the current lower and upper. Then after we 
  ;#     check this new guess, we either make it the next lower/upper
  ;#     and converge.

  set guess $initial_guess

  while { $attempt <= $max_attempts } {
    set one_plus_guess [ expr 1.0 + $guess ]
    for { set i 1; set sum $input(value,0) } { $i < $input(no_of_items) } { incr i } {
      set a [ expr $input(value,$i)/pow($one_plus_guess,$input(normalized_date,$i)) ]
      set sum [ expr $a+$sum]
      if { [ info exists debug ] } {
        puts [ format "%d summing %d %4.4f %4.4f" $attempt $i $sum $a ]
      }
    }
    if { [ info exists debug ] } {
      if { [ info exists lower_limit ] } {
        set ll [ format %4.4lf $lower_limit ]
      } else {
        set ll "ll-ns"
      }
      if { [ info exists upper_limit ] } {
        set ul [ format %4.4lf $upper_limit ]
      } else {
        set ul "ul-ns"
      }
      puts [ format "%d %4.4f (%s %s) %f " $attempt $guess $ll $ul $sum  ]
    }
    if { abs($sum) <= $accuracy_factor } {
      ;# wow!
      return $guess
    }
    if { [ info exists lower_limit ] &&
         [ info exists upper_limit ] } {
      ;# we have alrady marked
      if { $sum > 0 } {
        set lower_limit $guess
      } else {
        set upper_limit $guess
      }
      set guess [ get_avg $lower_limit $upper_limit]
    } else {
      ;# we are yet to either atleast one limit
      if { $sum > 0 } {
        set lower_limit $guess
        set guess [ expr $guess + $step ]
      } else {
        set upper_limit $guess
        set guess [ expr $guess - $step ]
      }
    }
    incr attempt
  }

  puts "Ran out of attempts"
  exit 1
}

;# input(no_of_items)
;# input(value,i)
;# input(date,i)
;# input(month,i)
;# input(year,i)
proc get_xirr { input_arg } {

  upvar $input_arg input

  if { $input(no_of_items) < 2 } {
    puts "input(no_of_items) : $input(no_of_items) is < 2"
    exit
  }

  set epoch_first [ get_epoch $input(date,0) $input(month,0) $input(year,0) ]

  for { set i 1; set last $epoch_first } { $i < $input(no_of_items) } { incr i } {
    set epoch [ get_epoch $input(date,$i) $input(month,$i) $input(year,$i) ]
    if { $epoch <= $last } {
      puts "$i th date $input(date,$i)-$input(month,$i)-$input(year,$i) is less than the previous date [get_date $last a b c]"; 
      exit 1
    }
    set last $epoch
    set days [ get_difference_in_days_from_epoch $epoch_first $epoch ]
    set input(normalized_date,$i) [ expr $days/365.0 ]
  }
  return [ get_xirr_core input ]
}

proc get_xirr_for_input_in_file { file_name } {
  if { [ file isfile $file_name ] != 1 } {
    puts "Unable to open file $file_name"
    exit 
  }
  set fd [ open $file_name "r" ]
  set i 0
  while {1} {
    set line [gets $fd]
    if {[eof $fd]} {
      close $fd
      break
    }
    if { [ string is space $line ] } {
      ;# empty line
      continue
    }
    set date_pattern {([[:digit:]]{2})-([[:digit:]]{2})-([[:digit:]]{4})}
    set amount_pattern {-?[[:digit:]]+(\.[[:digit:]]{2})?}
    set space {[[:space:]]+}
    set pattern "$date_pattern$space"
    append pattern "($amount_pattern)"
    set res [ regexp $pattern $line discard dd mm yyyy amount]
    if { $res != 1 } {
      puts "line $line didn't match pattern $pattern"; exit 
    }
    set input(date,$i) $dd
    set input(month,$i) $mm
    set input(year,$i) $yyyy
    set input(value,$i) $amount
    incr i
  }

  set input(no_of_items) $i

  return [ get_xirr input ]
}

proc my_main { } {
  puts -nonewline "Enter the amount you invest:"; flush stdout;
  gets stdin investment  
  if { [ string is space $investment ] == 1 } { 
    puts "You must enter an amount" ; exit
  } elseif { [ string is double $investment ] == 0 } {
    puts "You should enter an amount value" ; exit
  } elseif { $investment <= 0 || $investment > 10000000 } {
    puts "allowed range (1-1,00,00,000)"; exit
  }

  puts -nonewline "Enter the date of investment - dd-mm-yyyy:"; flush stdout;
  gets stdin inv_date
  set res [ regexp {([[:digit:]]{2})-([[:digit:]]{2})-([[:digit:]]{4})} $inv_date discard inv_dd inv_mm inv_yyyy ]
  if { $res != 1 } {
    puts "$inv_date is not in dd-mm-yyyy format" ; exit
  }

  puts -nonewline "Enter the amount you got as return:"; flush stdout;
  gets stdin returns
  if { [ string is space $returns ] == 1 } { 
    puts "You must enter an amount" ; exit
  } elseif { [ string is double $returns ] == 0 } {
    puts "You should enter an amount value" ; exit
  } elseif { $returns <= 0 || $returns > 10000000 } {
    puts "allowed range (1-1,00,00,000)"; exit
  }

  puts -nonewline "Enter the date of encashment - dd-mm-yyyy:"; flush stdout;
  gets stdin ret_date
  set res [ regexp {([[:digit:]]{2})-([[:digit:]]{2})-([[:digit:]]{4})} $ret_date discard ret_dd ret_mm ret_yyyy ]
  if { $res != 1 } {
    puts "$ret_date is not in dd-mm-yyyy format" ; exit
  }

  puts "Investment: $investment"
  puts "inv-date: $inv_dd $inv_mm $inv_yyyy"
  puts "Returns: $returns"
  puts "returns-date: $ret_dd $ret_mm $ret_yyyy"
  set diff [ get_difference_in_days $inv_dd $inv_mm $inv_yyyy $ret_dd $ret_mm $ret_yyyy ]
  puts "You held for days: $diff"

  set cagr [get_cagr $investment $returns $diff]
  puts "Your returns (cagr):$cagr"
  
}

if { [info exists argv0] && [file tail [info script]] eq [file tail $argv0]} { 
  my_main
}

