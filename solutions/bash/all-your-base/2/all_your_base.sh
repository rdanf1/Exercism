#!/usr/bin/env bash
# DR - Ascen+31 - 2025
#
# Maths
#
#	to switch from 1 base (b1) number nb1 
#	           to another (b2) number nb2
#
#	we must count base1 nb1 into base2 nb2
#       from units to nth degree respectively
#       actually the convention notation says
#       we group in sets of (b2 - 1) symbols
#       any number, and when reaching b2 we reset
#       to 0 and switch left to the upper digit, etc..
#
#	so to avoid this fastidious counting 1 by 1,
#	                   (or counting set1 into set2)
#
#	we transform b1 nb1 to decimal b0 nb0 
#	                          (bash knows it!)
#
#	[a] then get the higher set of sets in b2 > nb0
#	as b2^N > nb0 => 1st highest digit 
#	                 = (N-1)th digit of value 
#	as q*b2^(N-1) < nb0 [ nb0/(b2^(N-1)) gives q ]
#
#	then remove digit found to nb0 :
#	[b] nb0 = nb0 - q*b2^(N-1)
#
#	and recurre to [a] searching down from (N-2)..
#
#	seems faster way to proceed : from highest digit
#	                                to lowest.
#	                              (ending with units)
#
# End Maths
#
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
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
}

# Figure out input shape as
#                required/correct
test_regex () {

	for i in "${!Input[@]}"
	do
		printf2 "Input i:" "${Input[$i]}"
	done

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with :
	#
     #   "Usage : $0 <base1> ".. <digit1> <digit0>" <base2>
	#
REGEX_PARAMS=\
'^[1-9][0-9]*\( [0-9][0-9]*\)*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[1-9][0-9]*( [0-9][0-9]*)*$'

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

	    # Saw in @tests
	    #
	    [[ ${Input[0]} -gt 1 ]] \
	 && [[ ${Input[2]} -gt 1 ]] \
	 && [ "${Input[1]}" == "" ] \
	 && echo "0" && exit 0 

	    # Whatever ( said bob.. )
echo "Usage: $0 <base1> \".. <digit1> <digit0>\" <base2>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0-n]} are Integers
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    [[ ${Input[0]} -le 1 ]] \
	 || [[ ${Input[2]} -le 1 ]] \
	 && echo "error base" && exit 2 
	    
	    # One single parameter is level
	    #  and no bonus..
	    #
	    [[ "$#" -ne 3 ]] \
	 && echo "3 parameters are needed!" && exit 1
	    

	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

base2_digits () {

	# Arrays of digits for each base
	#          Input         Result
	#
	declare -a base_1=( $2 ) base_2=( )
	
	# Initial values
	#
	declare -i N=0 i=0 base1="$1" nb0=0 \
		           base2="$3"
	
	printf2 "@base_1" "${base_1[@]}"
	printf2 "base2 :" "$base2"

	# Create nb0 ( = base 10 input number )
	#    (from base1 and its digits)
	#
	for i in $(seq "$(("${#base_1[@]}" -1))" -1 0)
	do
		# 1st Check validity of digit
		[[ "${base_1[i]}" -ge "$base1" ]] \
	     && echo "Error digit >= base" \
	     && exit 2

		# 2d add to decimal
		nb0+=$(( base_1[i] * (base1 ** N) ))
		((N++))
		printf2 "nb0 for:" "$nb0"
	done
	
	N=0
	Nb=0
	# Find greatest power of base2 > nb0
	#
	while [[ "$nb0" -gt "$Nb" ]]
	do
		Nb=$((base2 ** N))
		((N++))
		printf2 "Nb while:" "$Nb"
	done

	((N--))
	# Browsing down to lower powers of base2
	#
	while [[ "$((N - 1))" -ge 0 ]]
	do
	    printf2 "nb0 :" "$nb0"
	    printf2 "N-1 :" "$((N - 1))"
	    printf2 "base2^(n-1) :" "$((base2 ** (N - 1)))"
	    digit_b2="$(( nb0 / (base2 ** (N - 1)) ))"
	    base_2+=( "$digit_b2" )

	    # += - <=> -=
	    #   v
      nb0+="$(( - "$digit_b2" * (base2 ** (N - 1)) ))"
	     ((N--))
	done

	# Last digit is remaining units
	#   ( sometimes is missing.. )
	#
	[[ "${#base_2[@]}" -lt 1 ]] \
     &&	base_2+=( "$nb0" )

	printf2 "@base_2" "${base_2[@]}"

	# Result
	#
	echo "${base_2[@]}"
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
		base2_digits "$@"
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

