#!/usr/bin/env bash
# DR - Ascen+17 - 2025
#
# Maths
#
#	We count odds and shift bits to the right
#	until reaching 0.
#
# End Maths 
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

is_pair () {
	
	return "$(( "$1" % 2 ))"
}

test_params () {

	# for grep :   escapes for ?,+,-,(,), etc... 
	#            & quotes in grep arg
	#
	# Any Number positive [0-9]+ => Ok !
	#
	REGEX_PARAMS='^[0-9]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	# Any Number positive [0-9]+ => Ok !
	#
	REGEX_PARAM2='^[0-9]+$'

	# nb: debug printf2 != printf !! 
	#     in function $@->$*  => args ok 
	#
	#Input="$(printf2 "$@" | xargs)"

	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	# At least : MORE ! (Master of Reg. Expr!)
	#  [ Deep // tests.. ]
	#
	printf2 "$Input" | grep "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ $Input =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! $Input =~ $REGEX_PARAM2 ]]
	then
		printf2 "Imput Wrong Regex"
# Whatever ( said bob.. )
echo "1 argument expected"
		exit 4
	else
	        printf2 "Imput Ok"
		return 2
	fi
}

Count_Eggs () {

    if [[ "$1" -gt "0" ]] 
    then
	! is_pair "$1" && ((Eggs+=1))
	Count_Eggs "$(($1 >> 1))"
    else
	echo $Eggs
    fi
}


main () {

    # Test arguments
    test_params "$@"

    Return=$?

	

    # Process
    case "$Return" in
	    2)
		Eggs=0
		printf2 "Count_Eggs : " "$1"
		Count_Eggs "$1"
		
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

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99
#

