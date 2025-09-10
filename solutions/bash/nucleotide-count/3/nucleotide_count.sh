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
'^\(A\|C\|G\|T\)\+$'

#'^[\!-z]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	REGEX_PARAM2=\
'^(A|C|G|T)+$'

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
	    # Empty chain is ok
	    [ "$*" == "" ] && \
	    return 0
	    
	    # Whatever ( said bob.. )
	    echo "Invalid nucleotide in strand"
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
    # Uppercase
    Input=${Input@U}
    printf2 "Input : " "$Input"
}

is_ADN () {

    # Return [values counted +1] (so A,C,G,T ≠ 0
    #                 +1          no line to add,
    #                vvvv         empty chain ok)
    is_acgt="$(echo "ACGT""$Input" \
	     | sed 's/./& \n/g' \
	     | sort | uniq -c)"
    
    printf2 "is_acgt1 : " "$is_acgt"

    # Transforms to output desired
    #
    is_acgt="$(echo "$is_acgt" | sed -E 's/([0-9]+) (A|C|G|T)/\2: \1/' | grep 'A\|C\|G\|T' )"
    # remove double spaces
    is_acgt="${is_acgt//  /}"

    printf2 "is_acgt2 : " "$is_acgt"

    # j is an integer
    declare -i j=0  
    # optional ( store strand values 
    #            in association array )
    #declare -A strand=( )

    # Substract 1 and to previous form
    #   and display result
    #
    while read -r i j
    do 
	    j+=-1
	    #strand+=( [$i]=$j )

	    # The response display
	    echo "$i" "$j"

    done < <(printf "%s\n" "$is_acgt")

    #printf2 "${!strand[@]}"
    #printf2 "${strand[@]}"
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
		is_ADN 
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

