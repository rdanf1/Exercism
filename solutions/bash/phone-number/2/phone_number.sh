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
	# any alphanum or more 
	#
	REGEX_PARAMS=\
'^[ -~]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	REGEX_PARAM2=\
'^[ -~]+$'

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
	    echo "Invalid number.  [1]NXX-NXX-XXXX N=2-9, X=0-9"
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

	Input="$(echo "$Input" | tr -cd '0-9')"

	# Having 10 digits is ok..
	printf2 "Input Formatted :" "$Input"
	printf2 "#Input Formatted :" "${#Input}"
	[[ "${#Input}" -eq 10 ]] \
     && printf2 "I::1" "${Input::1}" \
     && [[ "${Input::1}" -gt 1 ]] \
     && [[ "${Input:3:1}" -gt 1 ]] \
     && printf2 "I:3:1" "${Input:3:1}" \
     && echo "$Input" && exit 0

	# Check and remove country prefix if any
	#
	[[ "${#Input}" -eq 11 ]] \
     && [[ "${Input::1}" -eq 1 ]] \
     && printf2 "I::1" "${Input::1}" \
     && [[ "${Input:1:1}" -gt 1 ]] \
     && printf2 "I:1:1" "${Input:1:1}" \
     && [[ "${Input:4:1}" -gt 1 ]] \
     && printf2 "I:4:1" "${Input:4:1}" \
     && echo "${Input:1}" && exit 0

	echo "Invalid number.  [1]NXX-NXX-XXXX N=2-9, X=0-9" && exit 1
}

is_Isogram () {

    # Return duplicate values if any
    #
    isnt_isogram="$(echo "$Input" | sed 's/./&\n/g' \
		  	          | sort | uniq -d)"
    
    printf2 "Isn_isogram : " "$isnt_isogram"
    printf2 "#Isn_isogram : " "${#isnt_isogram}"

    # Return (0 if isogram = nb of duplicates)
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

