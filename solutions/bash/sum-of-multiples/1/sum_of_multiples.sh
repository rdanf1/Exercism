#!/usr/bin/env bash
# DR - Ascen+31 - 2025
#
# Maths
#
#   See Readme
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
	#  conforms with
	#   "Usage : $0 <level> <bonus1, bonus2..>"
	#
REGEX_PARAMS=\
'^[1-9][0-9]*\( [0-9][0-9]*\)\*$'

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

	    # Whatever ( said bob.. )
    printf2 "Usage : $0 <level> <bonus1, bonus2..>"
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
	    
	    # One single parameter is level
	    #  and no bonus..
	    #
	    [[ "$#" -eq 1 ]] \
	 && echo "0" && exit 0
	    
	    # Testing if all bases > level
	    #  => zero
	    #
	    ARGS="${#Input[@]}"
	    i=1
	    j=1
	    while [[ "$i" -lt "$ARGS" ]]
	    do
	    [[ "${Input[0]}" -lt "${Input[i]}" ]] \
		    && ((j++))
	    ((i++))
	    done

	    [[ "$j" -eq "$ARGS" ]] \
	 && echo "0" && exit 0


	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

find_tuples () {
	declare -i current=0 current2=0

	level="$1"
	if [[ "$2" -ne 0 ]]
	then
	  current2="$2"
	  current="$2"
	  printf2 "current :" "$current"
	  while [[ "$level" -gt "$current" ]]
	  do
		Tuples+=( "$current" )
		current+="$current2"
	  printf2 "current while:" "$current"
	  done
	fi
	# 1st shift for level
	#       2d for next base..
	shift; shift

	# If next base exist recurre on it
	#  ( keep args unquoted )
	#
	[[ -n "$1" ]] \
     && find_tuples "$level" $*

	printf2 "Tuples :" "${Tuples[@]}"
}

summarize_tuples () {

	declare -i j=0 i=0

	tuples="$(echo "${Tuples[@]}" | sed 's/ /\n/g' | sort | uniq | xargs)"
	printf2 "tuples :" "$tuples"

	# Not to quote
	#
	for i in $tuples
	do
		j+="$i"
	done

	printf2 "The result is :" "$j"
	echo "$j"
}

main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )

    # Partial result (with duplicates)
    declare -a Tuples=( )

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		find_tuples "$@"
		summarize_tuples
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

