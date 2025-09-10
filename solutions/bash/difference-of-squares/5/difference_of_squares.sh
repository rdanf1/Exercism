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
 
   echo_0 () {
	   echo 0
	   exit 0
   }

   echo_1 () {
	   echo 1
	   exit 0
   }

   default () {
	       echo "Usage : $0 <number> (not too high plz!)"
	       exit 1
   }

   default_01 () {
	   
	   case "$1 $3" in

	   	"difference_of_squares 0")
			echo_0
		   	;;

	   	"sum_of_square 0")
			echo_0
			;;

	   	"square_of_sum 0")
			echo_0
			;;

	   	"difference_of_squares 1")
			echo_0
		   	;;

	   	"sum_of_square 1")
			echo_1
			;;

	   	"square_of_sum 1")
			echo_1
			;;

	   	*)
			default
			;;

	   esac
   }

   diff_of_sqr () {

   	   # Trivial case with 2 :
	   if [ "$1" == "2" ]
	   then
		   echo 4 && exit 0
	   else          
	   	# we dig until reach the trivial
		# then let the magic operate !
		sol=$(( $( diff_of_sqr $(($1 - 1)) ) + \
			2 * $1 * $(sum_p $1) ))
	   fi

	   echo $sol
   }

   sum_of_sqrs () {

   	   # Trivial case with 2 :
	   if [ "$1" == "2" ]
	   then
		   echo 5 && exit 0
	   else          
	   	# we dig until reach the trivial
		# then let the magic operate !
		sol=$(( $( sum_of_sqrs $(($1 - 1)) ) + \
			$1 ** 2 ))
	   fi

	   echo $sol
   }

   sqr_of_sums () {

   	   # Trivial case with 2 :
	   # ( not recursive, though we use above functions... )
	   if [ "$1" == "2" ]
	   then
		   echo 9 && exit 0
	   else          
		   sol=$(( $( sum_of_sqrs $1 ) + \
		           $( diff_of_sqr $1 ) ))
	   fi

	   echo $sol
   }

   main () {

	   # Some default values before Trivial
	   #  ( some tests may use those 
	   #    though I'd prefer omit these 
	   #    in a recurse script... )
	   #
	   [ "a$2" == "a" ] && default
	   [ "a$2" == "a0" ] && default_01 $1 $2 0
	   [ "a$2" == "a1" ] && default_01 $1 $2 1
	   ! ([ -n "$2" ] \
	   && [ "$2" -eq "$2" ]) 2>/dev/null && default 

	   case "$1" in
		   "difference_of_squares")
			diff_of_sqr $2
			   ;;
		   "sum_of_square")
			sum_of_sqrs $2
			   ;;
		   "square_of_sum")
			sqr_of_sums $2
			   ;;
		   *)
			default
			   ;;
	   esac

          


   }
#   # call main with all of the positional arguments
   main "$@"

