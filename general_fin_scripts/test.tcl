#!/usr/bin/tclsh

source compute_cagr.tcl

set xirr [ get_xirr_for_input_in_file input ]

puts "xirr is $xirr"

