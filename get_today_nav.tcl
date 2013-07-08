#!/usr/bin/tclsh


set link "http://amfiindia.com/spages/NAV0.txt"
set default_file_name NAV0.txt

set now [ clock seconds ]

set date [ clock format $now -format "%Y-%m-%d" ]

puts $date

if { [ file exists $default_file_name ] == 1 }  {
  file delete $default_file_name
}

catch { exec wget $link }

if { [ file isfile NAV0.txt ] } {
  file rename $default_file_name "$date-today"
} else { 
  puts "NAV0.txt isn't found!"
}
