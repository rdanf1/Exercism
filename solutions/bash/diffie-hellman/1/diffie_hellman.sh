#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Maths : Cf Readme & @test
#         applying formulas
#


# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0

# Debugging
#    Usage: printf2 "<var descr.> :" "<var>"
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
	#   "Usage : $0 <some text>"
	#
REGEX_PARAM=\
'\(privateKey\|publicKey\|secret\)'
REGEX_PARAMS=\
"^$REGEX_PARAM\( [1-9][0-9]*\)\+$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM1=\
'(privateKey|publicKey|secret)'
REGEX_PARAM2=\
"^$REGEX_PARAM1( [1-9][0-9]*)+$"
#'^[ -~]*$'

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
    	    echo "Usage : $0 <some text>"
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
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_cipher () {

    if [ "$1" == "privateKey" ]
    then
	RAND=0
	while [[ "$RAND" -lt 2 ]]
	do
		RAND="$(( RANDOM % "$2" ))"
	done
	echo "$RAND"
    else
    if [ "$1" == "publicKey" ]
    then
	declare -i p="$2" g="$3" private="$4"

	# using bc because 
	#
	# $(( g ** private ) % p ) 
	#   and this exponent may lead to overflow
	#   => negative or wrong values..
	#
	bc <<< "($g^$private)%$p"
    else
    if [ "$1" == "secret" ]
    then
	declare -i p="$2" public="$3" private="$4"

	# bc because..
	#
	bc <<< "($public^$private)%$p"
    fi
    fi
    fi
}


main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )

    # Flat string version
    declare Input2=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		mk_cipher "$@"
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

