#!/usr/bin/env bash
# Reminder [ just maths... ] : 
#   ( a + b )^2 = a^2 + b^2 + 2ab                 => dif0 2ab
#   ( a + b + c )^2 = (a+b)^2 + c^2 + 2*(a+b)*c   => difp + 2c*(a+b)
#                   = Prec + c^2 + 2c*(a+b)
#
# => A recursive solution exists !
#

# We need this ( sum_p 4 = 3+2+1 )
# should be recursive too though...

   sum_p () {

	local sump=0
        #IFS='\n'
	for i in $( seq 0 $(($1 - 1)) )
	do
		((sump+=$i))
	done
        #IFS=' '
   
	echo $sump
   }

   default_1 () {
	       echo "0"
	       exit 0
   }


   default () {
	       echo "Usage : $0 <number> (not too high plz!)"
	       exit 1
   }

   main () {

	   # Some default values before Trivial
	   #  ( some tests use these maybe
	   #    though I'd prefer omit these 
	   #    in a recurse script... )
	   ! [ -n $1 ] && default
	     [ "a$1" == "a" ] && default
	     [ "a$1" == "a0" ] && default
	     [ "a$1" == "a1" ] && default_1
           
   	   # Trivial case with 2 :
	   if [ "$1" == "2" ]
	   then
		   echo 4 && exit 0
	   else          
	   	# we dig until reach the trivial
		# then let the magic operate !
		sol=$(( $( $0 $(($1 - 1)) ) + \
			2 * $1 * $(sum_p $1) ))
	   fi

	   echo $sol
   }

#   # call main with all of the positional arguments
   main "$@"

