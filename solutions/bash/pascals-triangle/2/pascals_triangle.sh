#!/usr/bin/env bash
# DR - Ascen+31 - 2025
#
# Maths
#			1
#		       1 1
#  		      1 2 1
#  prec ->	     1 3 3 1 
#  curr	->	    1 4 6 4 1
#		   1 5 10 10 5 1
#		  1 6 15 20 15 6 1
#
#   row_curr(i) = row_prec(i-1) + row_prec(i)
#
# End Maths
#


# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0

# Debugging
#    Usage: printf2 "<echo param>" "<values..>"
#
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		printf '%s\n' "$*"
	fi
	# Always true
	return 0
}

# Functions

store_Input () {

	while [[ "$#" -gt 0 ]]
	do
	    Input+=( "$1" )
	    Input2+=" $1"
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
	    Input2="${Input2:1}"
	    printf2 "Input2 :" "$Input2"
}

# Figure out input shape as
#                required/correct
test_regex () {

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with
	#   "Usage : $0 <pascal's triangle level> (N)"
	#
REGEX_PARAMS=\
'^[0-9]\+$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[0-9]+$'

	#  [ Deep regex // tests.. ]
	#
	printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}


test_params () {

	# So called
	store_Input "$@"

	test_regex "$@"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #

	    # Whatever ( said bob.. )
    	    echo "Usage : $0 <pascal's triangle level> (N)"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0]} is 1 [A-Z] letter
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    [ "$Input2" == "0" ] \
	 && echo "" && exit 0
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_pascals () {


	declare -a row_prev=( ) row_curr=( 1 )
	spaces=""
	declare -i level=1

	while [[ "$level" -lt "$Input2" ]]
	do
		spaces+=" "
		((level++))
	done
	
	while [[ "$level" -gt 1 ]]
	do
	    printf "%s" "$spaces"
	    echo "${row_curr[*]}"
	    # nb : keep unquoted !
	    row_prev=( ${row_curr[*]} )
	    row_curr=( 1 )
	    i=1
	    printf2 "*row_prev :" "${row_prev[*]}"
	    printf2 "!row_prev :" "${!row_prev[@]}"
	    while [ "${row_prev[$i]}" != "" ]
	    do
		     row_curr+=( "$(( row_prev[((i - 1))] + \
			          row_prev[i] ))" )
	    	     printf2 "*row_curr while:" "${row_curr[*]}"
		    ((i++))
	    done

	    row_curr+=( 1 )
	    printf2 "*row_curr :" "${row_curr[*]}"

	    spaces="${spaces:1}"
	    ((level--))
	done

	# Last line of triangle (without spaces)
	#
	printf "%s\n" "${row_curr[*]}"
}


main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		mk_pascals "$@"
		    ;;
	    *)
		printf2 "An Invalid Input Occurred"
	        exit 1 
		    ;;
    esac

    exit 0
}


# Call main with all of the positional arguments
   main "$@"

