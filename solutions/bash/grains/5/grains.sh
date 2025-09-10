#!/usr/bin/env bash
# DR - Asc+4 - 2025
# Reminder ( Maths series )
# 0*1 + 2*1 + 2*2 = geometric serie with reason 2
# N0 + 2*N0 + 2*2*N0 + 2^3*N0 + 2^4*N0 + .. + 2^N*N0
#
# So recurrence is :
# U0=1 ; Un+1 = 2^n*N0 =>  Un+1 = 2^n  
#
# Here we can say there is a problem...
# knowing bash usually use long signed number (%ls)
# and the limit is 2^63 -1
# we can push it in unsigned long with 
#    printf "%lu" <very big number>
# though we reach a 2d limit that is 2^64 - 1
# so for being successful with 2^64 
# we need to do the last operation [+1] with chars...
# printf "%lu" $((2 ** 64 - 1)) gives :
#
#   18446744073709551615 | 
# + 00000000000000000001 |  beside notice %lu overflow :
# ---------------------- |  $ echo $((18446744073709551616)) 
# = 18446744073709551616 |  0      
#                        |  
# CQFD/WWTP              |  and signed long default so :
#                        |  $ echo $((18446744073709551615)) 
#                        |  -1
# Conclusion 
#    I dont think this exercice needs to recreate addition
#    from unlimited numeric strings
#    So we keep it as a upper limit the 64 case
#    and join it to trivial value...
#
# #################################
# FORGET ALL SAID ABOVE : WRONG !
# #################################
#
#                       [ current val : Prec Sum Val  + Case value
# Solution is recurrent [ sum value N : sum value N-1 + 2^(N-1)
#   
#   printf "%lu\n" $(($sum_prec + 2 ** $ind_prec ))
#
# TODO :
# 1. Exponent function in recursive way ...
# 2. Powers of twos are quite simple binary way : 
#     10  << 1 = 100   : 2^2
#     100 << 1 = 1000  : 2^3
#     etc...
# 3. Both 1. & 2. :-)

   usage () {
	       #echo "Usage: $0 <number> (64 maximum!)"
	       echo "Error: invalid input"
	       exit 1
   }

   # WARNING : MUCH TOO SLOW... ( 2 ** is really better ) 
   # redo with rot and binary mode..
   power_2 () {
	   if [ "$1" == "1" ]
	   then
		   echo 2
	   else
		   #printf "%ls\n" $(($(power_2 $(($1 - 1))) * 2))
		   echo $(($(power_2 $(($1 - 1))) * 2))
	   fi
   }

   Sum_geom_2 () {
	   
	       local sum_prec
	       local ind_prec
               if [ "$1" == "1" ]
	       then
		       echo 1
		       exit 0
	       else
		       ind_prec=$(($1 - 1))
		       sum_prec=$( Sum_geom_2 $ind_prec )
		       #printf "%lu\n" $((sum_prec + $(power_2 ind_prec) ))
		       printf "%lu\n" $((sum_prec + 2 ** ind_prec ))
		       #echo $((sum_prec + 2 ** ind_prec ))
	       fi

   }

   main () {
       
       # One parameter
       [ "$#" != "1" ] && usage
       [ "$1" == "total" ] && Sum_geom_2 64 && exit 0
       [[ "$1" -gt "64" ]] && usage
       [[ "$1" -lt "0" ]]  && usage
       [[ "$1" -eq "0" ]]  && usage

# Some tests were needed...
#       for i in $(seq 1 10)
#       do
#      		power_2 "$i" 
#       done

# Tricked overflow case putting good value in manual way...
#[ "$1" == "65" ] && echo "18446744073709551616" && exit 0 

       # Not empty and is numeric
       if [ "a$1" != "a" ] \
       && [ -n  "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null 
           then
                   [ "$1" -eq "0" ] && echo 0 && exit 0
		   #printf "%lu\n" $(Sum_geom_2 $1)
		   printf "%lu\n" $(( 2 ** $(($1 - 1)) ))
           else
	      	   usage 
      fi
   }

#   # call main with all of the positional arguments
   main "$@"

