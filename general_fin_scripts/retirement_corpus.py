#!/usr/bin/python

import sys

WelcomeMessage='''
This program computes the corpus you should have at the beginning of every year as you live, so that you can happily say
                              "I can stop working now for my sustenance."

It needs your present age, age till you expect your corpus to serve you (till your/your dependants death,say),
rate of return you get on ur savings, inflation rate and your current montly expenses
It simply presents the corpus required at each year such that it can both give you the expenses required for that year and with
the required money left over which when re-invested sustains your inflation adjusted expenses till the required age.
values in brackets are suggested examples. You can give your actual values. This program doesn't store your inputs. Your privacy is not compromised :)
'''

age_input         =  ("Enter your present age",30,int,
                        "Need Integral Age value",18,121,"Sorry This program is only for atleast 18-aged mortals")
sustain_age_input =  ("Enter your expected age for which you need ur corpus to be available",75,int,
                        "Need Integral Age value",18,121,"Sorry This program is only for atleast 18-aged mortals")
returns_input     =  ("Enter your expected rate of returns on investment",8.0,float,
                        "Need Numerical Values",0,30, "You ought to be realistic with ur returns")
inflation_input   =  ("Enter your expected inflation percentage",7.0,float,
                        "Need Numerical Values",0,30, "You ought to be realistic with inflation")
expenses_input    =  ("Enter your monthly expenses as of today",35000,int,
                        "Need Integral values",0,1000000,"Be realistic.If you spend so much, you dont need this calculator!")

def general_input_getter(prompt,def_val,cast_fn,cast_string,lower_bound,upper_bound,range_string):
  str_val=raw_input(prompt+" (%s):"%(def_val))
  if not str_val:
     val = def_val
  else:
     try:
        val = cast_fn(str_val)
     except ValueError:
        print (cast_string + "Got %s"%str_val)
        sys.exit(1)
  if val < lower_bound or val > upper_bound:
     print (range_string + ". Allowed range (%s-%s). Got %s"%(lower_bound, upper_bound, val))
     sys.exit(1)
  return val

print WelcomeMessage
age = general_input_getter(*age_input)
sustain_age = general_input_getter(*sustain_age_input)
returns = general_input_getter(*returns_input)
inflation = general_input_getter(*inflation_input)
expenses = general_input_getter(*expenses_input)

expenses_per_year = [0] * sustain_age
corpus_at_year = [0] * sustain_age

expenses_per_year[age]=expenses*12
inf = 1.0 + (inflation/100.0)
for i in range(age+1,sustain_age):
  expenses_per_year[i] = expenses_per_year[i-1]*inf

# let calculate corpus needed at beginning to support year-n and work backwards.

rr = 1.0 + returns/100.0
corpus_at_year[sustain_age-1] = expenses_per_year[sustain_age-1]
prev_corpus = corpus_at_year[sustain_age-1]
for i in range(sustain_age-2,age-1,-1):
  corpus_at_year[i] = expenses_per_year[i] + (prev_corpus/rr)
  prev_corpus = corpus_at_year[i]

for i in range(age,sustain_age):
  print ("At year %2d, you start with corpus %11.2lf. You spend %11.2lf on monthly inflated expense of %11.2lf and left with corpus %11.2lf"%
             (i,corpus_at_year[i],expenses_per_year[i],expenses_per_year[i]/12,corpus_at_year[i]-expenses_per_year[i]))

print ("Happy wealth Building")
