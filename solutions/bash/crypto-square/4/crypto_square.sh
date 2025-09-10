#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Analyse


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
REGEX_PARAMS=\
'^[ -~]*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[ -~]*$'

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

	    # Normalize input
	    #
	    Input2="$(echo "$Input2" | tr -d '[:punct:]')"
	    Input2="$(echo "$Input2" | tr -d ' ')"
	    Input2="$(echo "$Input2" | tr '[:upper:]'  '[:lower:]')"
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_cipher () {

	result=""
	size_input="${#Input2}"

	# getting integer part of sqrt from bc
	#
	cols=$(bc <<<"sqrt("$size_input")")

	while [[ $((cols * cols)) -lt "$size_input" ]]
	do
		((cols++))
	done

	rows=$((cols - 1))

	if [[ "$((cols * rows))" -lt "$size_input" ]]
	then
		rows="$cols"
	fi

	printf2 "rows : " "$rows"
	printf2 "cols : " "$cols"

	for i in $(seq 1 "$rows")
	do
	    for j in $(seq 1 "$cols")
	    do
		char="${Input2:0:1}"

		# Not to forget !
		#
		if [ "$char" != "" ]
		then
		    result+=( ["$i$j"]="${Input2:0:1}" )
		    Input2="${Input2:1}"
		else
		    # padding..
		    #
		    result+=( ["$i$j"]=" " )
		fi
	    done
	done
	for j in $(seq 1 "$cols")
	do
	    for i in $(seq 1 "$cols")
	    do
		    printf "%s" "${result["$i$j"]}"
	    done
	    # space between results
	    #
	    [[ "$j" -ne "$cols" ]] \
	   && printf ' ' 
	done
	printf '\n'
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

