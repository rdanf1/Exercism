#!/usr/bin/env bash
# DR - Ascen+40 - 2025
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
	    Input2+=" $1"
	    printf2 "Input  while :" "${Input[@]}"
	    shift
	done
	    Input2="${Input2:1}"
	    printf2 "Input2 :" "$Input2"
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
	#
	#  conforms with :
	# Usage : $0 <Any Integers>
	#
REGEX_PARAMS=\
'^[0-9]*\( [0-9]*\)*$'

	# Same as above limited to lowers or digits
	#                       or apostrophes
	#                       or spaces
	#
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[0-9]*( [0-9]*)*$'
#'^[ -~]*$'

	#  [ Deep regex // tests.. ]
	#
	printf2 "${Input[*]}" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

     #
     # 
     #
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
	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #

	    # Whatever ( said bob.. )
echo "Usage: $0 <nb to find> \"<nb1> <nb2> .. <nbN>\""
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[@]} 
	#   is whatever it is
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
# miss-understanding of @test
#	    [[ "$#" -ne 2 ]] \
#&& echo "Usage: $0 <nb to find> \"<nb1> <nb2> .. <nbN>\"" \
#&& echo "2 parameters needed" && return 2

	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

bin_search () {
	
    to_find="$1"
    shift	
    declare -a Search_array=( "$@" )
    declare -i size_arr="${#Search_array[@]}" \
	       nb_set=0 offset=0
	
    # 1st indice cut
    nb_set=$(( ("$size_arr" / 2) - 1))

    while [[ "$nb_set" -ge 0 ]] \
       && [[ "$nb_set" -le "$size_arr" ]]
    do
	# found the value ?
	[[ "${Search_array[$nb_set]}" -eq "$to_find" ]] \
     && echo "$((nb_set + offset))" && return 0

        if [[ "${Search_array[$nb_set]}" -gt "$to_find" ]]
	then
	    # current value is greater than searched one
	    ((nb_set--))

	    # lower boundary reached ?
	    [[ "$nb_set" -eq -1 ]] \
            && echo "-1" && return 0

	    # Cutting the upper part of the array
	    #
	    # nb 0:1 is 1st value of array ( = arr[0] ! )
	    #   then using (nb_set+1) >------------v-----v-v
	    Search_array=("${Search_array[@]:0:$((nb_set + 1))}")
	    size_arr="${#Search_array[@]}"

	else
	    # current value is lower than searched one
	    ((nb_set++))

	    # Upper boundary reached ?
	    [[ "$nb_set" -gt "$size_arr" ]] \
            && echo "-1" && return 0

	    # The array will be cutted on next command,
	    #   keeping as an offset value for result
	    #   the cutted part..
	    #
	    offset+="$nb_set"

	    # Cutting the lower part of the array
	    #
	    # nb 'arr[@]:N' is nth value of array (=arr[n-..])
	    #        and others values of indices above..
	    #   then using (nb_set) >-----------v
	    Search_array=("${Search_array[@]:$nb_set}")
	    size_arr="${#Search_array[@]}"
	fi
	# Cutting index value of new truncated array
	# 	before while loop (binary search !)
        nb_set=$(( ("$size_arr" / 2) - 1))
    done

    # didnt check this above..
    #
    [[ "${Search_array[0]}" -eq "$to_find" ]] \
 && echo $((0 + offset)) && return 0
    
    echo "-1" && return 0
}



main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )
    
    # Simple string version of Input
    declare Input2=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		bin_search "$@"
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

