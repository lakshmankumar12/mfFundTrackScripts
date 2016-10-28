#!/usr/bin/tclsh


puts ""
puts "This program computes the corpus you should have at the beginning of every year as you live, so that you can happily say "
puts "                              \"I can stop working now for my sustenance\". "
puts ""
puts "It needs your present age, age till you expect your corpus to serve you (till your/your dependants death,say), "
puts "rate of return you get on ur savings, inflation rate and your current montly expenses"
puts "It simply presents the corpus required at each year such that it can both give you the expenses required for that year and with "
puts "the required money left over which when re-invested sustains your inflation adjusted expenses till the required age."
puts "values in brackets are suggested examples. You can give your actual values. This program doesn't store your inputs. Your privacy is not compromised :)"
puts ""

puts -nonewline "Enter your present age (30):"
flush stdout
gets stdin age 
if { [ string is integer -strict $age ] == 0 } { puts "Need integral inputs" ; exit 1 }
if { $age < 18 || $age > 120 } { puts "sorry this program is only for alteast 18-aged mortals. Allowed range (18-120) " ; exit 1 }

puts -nonewline "Enter your expected age for which you need ur corpus to be available (75):"
flush stdout
gets stdin sustain_age
if { [ string is integer -strict $sustain_age ] == 0 } { puts "Need integral inputs" ; exit 1 }
if { $sustain_age <= $age } { puts "You can't be already dead" ; exit 1 }
if { $sustain_age > 120 } { puts "sorry this program is only for mortals. Allowed range (age+1 - 120)" ; exit 1 }

puts -nonewline "Enter your expected rate of returns on investment (8):"
flush stdout
gets stdin return_rate
if { [ string is double -strict $return_rate ] == 0 } { puts "Need a number with only decimal digits" ; exit 1 }
if { $return_rate < 0 || $return_rate > 30 } { puts " You ought to be realistic with ur returns. Allowed range (0-30) " ; exit 1 }

puts -nonewline "Enter your expected inflation percentage (7):"
flush stdout
gets stdin inflation
if { [ string is double -strict $inflation ] == 0 } { puts "Need a number with only decimal digits" ; exit 1 }
if { $inflation < 0 || $inflation > 30 } { puts " You ought to be realistic with inflation. Allowed range (0-30) " ; exit 1 }

puts -nonewline "Enter your monthly expenses as of today (35000):"
flush stdout
gets stdin expenses
if { [ string is integer -strict $expenses ] == 0 } { puts "Need integral inputs" ; exit 1 }
if { $expenses <= 0 || $expenses > 10000000 } { puts "Sorry this is only for simple souls who spend decently. Allowed range (1-1Cr) " ; exit 1 }


set expenses_per_year($age) [ expr $expenses * 12 ]
set inf [ expr 1.0 + ($inflation/100.0) ]
for { set i [ expr $age +1 ] } { $i < $sustain_age } { incr i } {
  set j [ expr $i - 1 ]
  set expenses_per_year($i) [ expr $inf * $expenses_per_year($j) ]
}


;# let calculate corpus needed at beginning to support year-n and work backwards.

set i [ expr $sustain_age - 1 ] 
set no_years [ expr $sustain_age - $age - 1]
set rr [ expr 1.0 + ($return_rate/100.0) ]
set corpus_at_year($i) $expenses_per_year($i)
set prev_corpus $corpus_at_year($i)
for { set i [ expr $i -1 ] } { $i >= $age } { incr i -1 } {
  set corpus_at_year($i) [ expr $expenses_per_year($i) +  ($prev_corpus/$rr) ]
  set prev_corpus $corpus_at_year($i)
}

for { set i $age } { $i < $sustain_age } { incr i } {
  puts [ format "At year %2d, you start with corpus %11.2lf. You spend %11.2lf and left with corpus %11.2lf"  $i  $corpus_at_year($i) $expenses_per_year($i) [ expr $corpus_at_year($i) - $expenses_per_year($i)] ]
}

puts "Happy wealth Building"
