#!/usr/bin/env bash
# DR - Ascen+31 - 2025
#
# Maths
#
#        Using an implementation ( for C-Z cases )
#        constructing half diamond
#        then restitute the remaining 
#        part from it
#
# End Maths
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

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with
	#   "Usage : $0 <diamond level> (A-Z)"
	#
REGEX_PARAMS=\
'^[A-Z]$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[A-Z]$'

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
    	    echo "Usage : $0 <diamond level> (A-Z)"
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

declare -a Source=( )
Source=( $(echo {A..Z}) )
printf2 "@Source :" "${Source[@]}"

# Only available from C to Z !!
#
mk_diamond () {


        declare -a half_result=( )
	spaces=""
	spaces2=""
	i=0
	while [ "${Source[i]}" != "${Input[0]}" ]
	do
		spaces+=" "
		((i++))
	done
	
	# print 1st A :
	#
	j=0
	half_result+=( "$(printf "%s%s%s\n" "$spaces" \
		              "${Source[j]}" \
			      "$spaces")" )

	# B has a single space in-between
	#
	j=1
	    spaces="${spaces:1}"
	    spaces2+=" "
	    half_result+=( "$(printf "%s%s%s%s%s\n" \
		                  "$spaces"      \
		                  "${Source[j]}" \
		                  "$spaces2"     \
		                  "${Source[j]}" \
				  "$spaces")" )

	# C-Z half construct
	#       (spaces2 growth by +2)
	#       (spaces  reduce by -1)
	j=2
	while [ "${Source[j]}" != "${Input[0]}" ] \
	   && [ "${Source[j]}" != "" ]
	do
	    spaces="${spaces:1}"
	    spaces2+="  "
	    half_result+=( "$(printf "%s%s%s%s%s\n" \
		                  "$spaces"      \
		                  "${Source[j]}" \
		                  "$spaces2"     \
		                  "${Source[j]}" \
				  "$spaces")" )
	    ((j++))
	done

	# Last one (actually middle)
	#
	    spaces="${spaces:1}"
	    spaces2+="  "
	    half_result+=( "$(printf "%s%s%s%s%s\n" \
		                  "$spaces"      \
		              	  "${Source[j]}" \
		                  "$spaces2"     \
		                  "${Source[j]}" \
				  "$spaces")" )

	printf2 "!half_result" "${!half_result[@]}"

	for i in "${!half_result[@]}"
	do
		echo  "${half_result[i]}"
	done

	# Using seq decrement
	#
	for i in $(seq $((${#half_result[@]} - 2)) -1 0)
	do
		echo  "${half_result[i]}"
	done
}


main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		# 2 trivial cases
	        [ "${Input[0]}" == "A" ] \
	     && echo "A" && exit 0

	        [ "${Input[0]}" == "B" ] \
	     && printf "%s\n%s\n%s\n" " A " "B B" " A " \
	     && exit 0

		# if >= "C"
		mk_diamond "$@"
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

