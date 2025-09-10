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
	# 1, 2 or more words <aa-bb cc dd>
	#
 REGEX_PARAMS=\
'^[A-z]\+\(\( \|-\)[A-z]*\)*$'

#'^[\!-z]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	# 1 single word 
	#
	REGEX_PARAM2=\
'^[A-z]+(( |-)[A-z]*)*$'

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
            # Refining Regex Wrong cases 
  	    #
	    [ "$*" == "" ] && \
	    echo "true" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "Word, or componed word or name"
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

format_Input () {

    # Using bash internals !
    #
    # Lowercase
    Input=${Input@L}
    printf2 "Input : " "$Input"
    # Remove '-'
    Input=${Input//-/}
    printf2 "Input : " "$Input"
    # Remove spaces
    Input=${Input// /}
    printf2 "Input : " "$Input"
}

is_Isogram () {

    # Return duplicate values if any
    #
    isnt_isogram="$(echo $Input | sed 's/./&\n/g' \
		  	        | sort | uniq -d)"
    
    printf2 "Isn_isogram : " "$isnt_isogram"
    printf2 "#Isn_isogram : " "${#isnt_isogram}"

    # Return 0 
    #
    return "${#isnt_isogram}"
}

main () {

    declare Input=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		format_Input
		if is_Isogram ;
		then
			echo "true"
		else
			echo "false"
		fi
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

