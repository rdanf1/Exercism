#!/usr/bin/env bash
# DR - Ascen+25 - 2025
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

test_params () {

	# for grep :   escapes 
	#            & quotes in grep arg
	# 1 number
	#
 REGEX_PARAMS=\
'^[0-9]\+$'
#	'^[A-z]\+\(\( \|-\)[A-z]*\)*$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	REGEX_PARAM2=\
'^[0-9]+$'

	# Warn
	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	#  [ Deep regex // tests.. ]
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
            # Refining Regex Wrong cases 
  	    #
	    [ "$*" == "" ] && \
	    echo "" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "1 Natural Number required"
	    return 4
	else
	    #
            # Refining Regex Checks
  	    #
	    :

	    printf2 "Arguments Ok !"
	    return 0
	fi
}

Factors () {

    [[ "$1" -le "1" ]] && echo "" && exit 0
    # External part of nix utilities : 'factor'
    #
    factor "$1" | sed -r 's/.*:.([0-9])/\1/' | tr -d '*'

}

main () {

    declare Input=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		Factors "$Input"
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

