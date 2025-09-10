#!/usr/bin/env bash
# DR - Ascen+52 - 2025
#
# Maths
#
#  A ) We need to compute sqrt(x)
#      with basic operations provided by bash
#
#  1. Digits Approximation of sqrt ...
#  2. Heron's method
#  3. ..
#	
#  2. Seems easier :
#  => Using heron with 1st overestimate X = 1/2 * S
#     Then iterate X₂ = (S/X₁ - X₁ )/2   (heron's formula)
#	   until X dont change => X is √S (integer part of..)
#
#  Note : Pretty easy to get 2 decimals precision (*10^4)
#         take $(sqrt_of $((S * 10000))) 
#         and printf float adding '.' in rev. 2d pos.
#                         
# End Maths 
#
# 

# Debug mode [ mainly  for echoes from
#             'printf2 function' >1 => echo
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
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
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
}

# Figure out input shape as
#                required/correct
test_regex () {

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with  
	#         "Usage : $0 <Natural Number>"
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
	printf2 "${Input[@]}" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "${Input[*]}" =~ $REGEX_PARAM2 ]] \
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
	if [[ ! "${Input[*]}" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #

	    # Whatever ( said bob.. )
	    printf2 "Usage : $0 <Natural Number>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0]} is Integer
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #

	    # Un-documented!
	    #
	    [ "$2" != "" ] && return 1

	    [[ "$#" -ne 1 ]] \
	 && echo "1 single parameter required (integer)" \
	 && exit 1
  	    
	 # In bash $((1 / 2)) = 0
	 # 
#	    [[ "$1" -eq 1 ]] \
#	 && echo "1" \
#	 && exit 0


	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}


sqrt_of () {

	local -i X="$(($1 / 2))" X_prev="$1"

	# Odds made pairs (+1):
	#  (and Trivial : √1=1 Ok!)
	#
	[[ $(($1 % 2)) -eq 1 ]] \
     && ((X++))

	# Works for 0 and ∀ S > 1
	#
	printf2 "X :" "$X"
	

	while [[ "$X_prev" -gt "$X" ]]
	do
		X_prev="$X"
		X="$(( (($1 / X_prev) + X_prev) / 2 ))"
		printf2 "X while :" "$X"
	done
	echo "$X"
}

sqrt_2d_of () {

	sqrt_of "$(($1 * 10 ** 4))" \
      | sed -E 's/([0-9][0-9])$/\.\1/'
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
		sqrt_of "${Input[0]}"
		    ;;
	    1)
		sqrt_2d_of "${Input[0]}"
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

