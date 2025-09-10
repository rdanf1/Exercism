#!/usr/bin/env bash
# DR - Ascen+26 - 2025
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
	# from space to ~ : Alphanum & Punct.
	#
	REGEX_PARAMS=\
'^[ -~]\+$'
#'^[\!-z]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	REGEX_PARAM2=\
'^[ -~]+$'
#'^[A-z]+(( |-)[A-z]*)*$'

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
	    echo "true" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "Usage : $0 <expr.with.brackets>"
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

    # Remove all but brackets :
    # tr complemented deletion-vv
    #                          ||
    Input="$(echo "$Input" | tr -cd '()[]{}')"
    
    printf2 "Input Formatted :" "$Input"
}

remove_empty_pairs () {
    
    #   then remove empty brackets pairs
    #
    remain="$1"

    while echo "$remain" | grep -q '()\|\[\]\|{}'
    do
    	remain=$(echo "$remain" | sed 's/()//g' \
         		        | sed 's/\[\]//g' \
			        | sed 's/{}//g')

	printf2 "remain while :" "$remain"
    done
	printf2 "remain last :" "$remain"

    # Once all consecutives succeeded removes done :
    #  whether it remains nothing => ok
    #       or it remains 1 or several brackets => ko
    #
    if [ "$remain" == "" ] 
    then
	    echo "true"
    else
	    echo "false"
    fi

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
		remove_empty_pairs "$Input"
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

