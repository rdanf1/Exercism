#!/usr/bin/env bash
# DR - Ascension + 4 {2025}
#
# Reminder [ just maths... ] : 
#  (for the hard stuff : difference of squares )
#
#   ( a + b )^2 = a^2 + b^2 + 2ab                 
#                                 => dif0 2ab
#   ( a + b + c )^2 = (a+b)^2 + c^2 + 2*(a+b)*c   
#                                 => difp + 2c*(a+b)
# => A recursive solution exists !
#
#   So recurrence formula is :
#            Actual = Prec + c^2 + 2c*(a+b)
# Or diff-o-sqrs(N) = diff-o-sqrs(N-1) + N^2 + 2N*(sump(N-1))
#
# See sump : 1st function declared : sum_p
#
# Reminder2 [ just maths... ] : 
#  (for the easy stuff : sum of squares)
#  And...
#   Recurrence formula is :
#  	     sum-o-sqrs(N) = sum-o-sqrs(N-1) + N^2 
#
# Reminder3 [ just maths... ] : 
#  (for the easiest stuff : square of sums)
#  Just...
#   Use the 2 recursive functions above !
#  	     sqr-o-sum(N) = sum-o-sqrs(N) + diff-o-sqrs(N) 
#
# Summary : Oops, I did it very effective ! ( I think. )
#           Thanks, :)
#

# We need this ( sum_p 4 = 3+2+1 )
# should be recursive too though...

   sum_p () {

	local sump=0
        
	for i in $( seq 0 $(($1 - 1)) )
	do
		((sump+=i))
	done
	echo $sump
   }
 
   echo_0 () {
	   echo "0"
	   exit 0
   }

   echo_1 () {
	   echo "1"
	   exit 0
   }

   default () {
	       echo "Usage : $0 <number> (not too high plz!)"
	       exit 1
   }

   default_01 () {
	   
	   case "$1 $3" in

	   	"difference 0")
			echo_0
		   	;;

	   	"sum_of_squares 0")
			echo_0
			;;

	   	"square_of_sum 0")
			echo_0
			;;

	   	"difference 1")
			echo_0
		   	;;

	   	"sum_of_squares 1")
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
	   	# we dig until reaching the trivial
		# then let the magic operate !
		sol=$(( $( diff_of_sqr $(($1 - 1)) ) + \
			2 * $1 * $(sum_p "$1") ))
	   fi

	   echo "$sol"
   }

   sum_of_sqrs () {

   	   # Trivial case with 2 :
	   if [ "$1" == "2" ]
	   then
		   echo 5 && exit 0
	   else          
	   	# we dig until reaching the trivial
		# then let the magic operate !
		sol=$(( $( sum_of_sqrs $(($1 - 1)) ) + \
			$1 ** 2 ))
	   fi

	   echo "$sol"
   }

   sqr_of_sums () {

   	   # Trivial case with 2 :
	   # ( not recursive, though we use above functions... )
	   if [ "$1" == "2" ]
	   then
		   echo 9 && exit 0
	   else          
		   sol=$(( $( sum_of_sqrs "$1" ) + \
		           $( diff_of_sqr "$1" ) ))
	   fi

	   echo "$sol"
   }

   main () {

	   # Some default values before Trivial
	   #  ( some tests may use those 
	   #    though I'd prefer omit these 
	   #    in a recurse script... )
	   #
	   [ "a$2" == "a" ] && default
	   [ "a$2" == "a0" ] && default_01 "$1" "$2" "0"
	   [ "a$2" == "a1" ] && default_01 "$1" "$2" "1"
	   ! ([ -n "$2" ] \
		   && [ "$2" -eq "$2" ]) 2>/dev/null && default

	   case "$1" in
		   "difference")
			diff_of_sqr "$2"
			   ;;
		   "sum_of_squares")
			sum_of_sqrs "$2"
			   ;;
		   "square_of_sum")
			sqr_of_sums "$2"
			   ;;
		   *)
			default
			   ;;
	   esac

   }

   #
   # Call main with all of the positional arguments
   #
   main "$@"

