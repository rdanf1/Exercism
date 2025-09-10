#!/usr/bin/env bash
# DR - Ascen+15 - 2025
#
# Maths :
#
# [ e(1), e(2), .. , e(k) ] // [ f(1), f(2), .. , f(k') ]
#
#   0.    [] equal [] or
#   1. [ a ] equal [ b ] <=> a = b .. (k=k')
#
#   2. [ a, b ] super of [] , [ a ] , [ b ]
#
#   Reciprocity :
#   3. [], [ a ], [ b ] sub of [ a, b ]
#
#   => Seems the search of smaller list in greater one
#      is the process to accomplish.
#
#   if sizes are equal the issues are :
#
#    - Equal if *all* elements at same place 
#        in each lists are identical.
#
#    - Inequal if *any* elements at same place
#        in each lists are different.
#
#   if List1 > List2 issues are :
#
#    - List1 is Super of List2 if *all* k' elements
#         of List2 can be found in a consecutive List1 serie 
#    - If List1 is super of List2 then
#         List2 is sub   of List1
#
#    - If List1 and List2 have no common element then
#         List1 is Inegual with List2
#
# Done
#
#    So grep should be ok with these..
#

# Debug mode [ mainly  for echoes from 
#             'echo2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
#    Usage: echo2 "<echo param>" "<values..>"
#
echo2 () {
	# TODO : Manage *any* echo parameters
	if [[ "$DEBUG" -gt "0" ]] 
	then
	   [ "$1" != "-n" ] && echo "$*"
	   [ "$1" == "-n" ] && shift && echo -n "$*"
	fi
	# Always true
	return 0	
}

# Functions

test_params () {

     	# Empty chain
     	#
	[ a"$*" == "a" ] \
     &&	echo "2 parameters needed" \
     &&	echo "Usage: $0 [<list 1>] [<list 2>]" \
     && echo2 "exit 1" && exit 1

	# Input available chains [unlimited]
	#
	# nb : Easily upgradable to any elements types
	#
	REGEX_1List='\[[0-9]+(, [0-9]+)*\]'
	REGEX_2Lists="^$REGEX_1List $REGEX_1List$"
	echo2 "REGEX_2Lists :" "$REGEX_2Lists" 

	REGEX_0List='\[\]'
	REGEX_00Lists="^$REGEX_0List $REGEX_0List$"

	
	REGEX_01Lists="^$REGEX_0List $REGEX_1List$"
	REGEX_10Lists="^$REGEX_1List $REGEX_0List$"
	

        [[ "$*" =~ $REGEX_2Lists ]] \
     &&	echo2 "2 available lists" \
     && echo2 "return 4" && return 4

        [[ "$*" =~ $REGEX_01Lists ]] \
     &&	echo2 "1st list empty" \
     && echo2 "return 1" && return 1

        [[ "$*" =~ $REGEX_10Lists ]] \
     &&	echo2 "2nd list empty" \
     && echo2 "return 2" && return 2

        [[ "$*" =~ $REGEX_00Lists ]] \
     &&	echo2 "Two lists empty" \
     && echo2 "return 3" && return 3


        echo "Usage: $0 [<list 1>] [<list 2>]" \
     &&	echo2 "Not a valid input" \
     && echo2 "exit 5" && exit 5

}

Input_2_Strings () {

	# Stripping [] from lists
	#
	# ':' is temporary separator of lists
	#
	# nb : Commas are kept and 1 more 
	#      is appended to each list
	#      for further comparisons..
	#
	echo "$*" | sed 's/\] \[/:/' \
		  | sed 's/\[//g'   \
		  | sed 's/\]//g'   \
		  | sed 's/, /,/g' \
		  | sed 's/:/, /g' \
		  | sed 's/$/,/g'
}

Solve () {

	declare -a Input=( $(Input_2_Strings "$@") )
	echo2 "{Input[@]} :" "${Input[@]}"

	size_list1="$(echo "${Input[0]}" | \
		      sed 's/,/\n/g' | wc -l)"
	size_list2="$(echo "${Input[1]}" | \
		      sed 's/,/\n/g' | wc -l)"
	echo2 "size_list1 :" "$size_list1"
	echo2 "size_list2 :" "$size_list2"

#	[[ "${#Input[0]}" -gt "${#Input[1]}" ]] \
 	[[ "$size_list1" -gt "$size_list2" ]] \
     && echo    "${Input[0]}" | \
	grep -q "${Input[1]}"   \
     && return 1

 	[[ "$size_list1" -lt "$size_list2" ]] \
     && echo    "${Input[1]}" | \
	grep -q "${Input[0]}"   \
     && return 2

        
 	[[ "$size_list1" -eq "$size_list2" ]] \
     && echo    "${Input[0]}" | \
	grep -q "${Input[1]}"   \
     && return 3
        
        return 0 
}


main () {

    test_params "$@"

    case "$?" in

	    1)
		    echo "sublist"
		    ;;
	    2)
		    echo "superlist"
		    ;;

	    3)
		    echo "equal"
		    ;;

	    4)
		    Solve "$@"

		    case "$?"  in
			    1)
		    		    echo "superlist"
				    ;;
			    2)
		    		    echo "sublist"
				    ;;
			    3)
				    echo "equal"
				    ;;
			    *)
				    echo "unequal"
				    ;;
		    esac
		    ;;
	    *)
		    echo "unequal"
		    ;;

    esac

    exit 0
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99
#
