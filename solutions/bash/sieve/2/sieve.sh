#!/usr/bin/env bash
# DR - Ascen+31 - 2025
#
# Maths
#
# 2>4 6 8 10 12 ..                n / n > Nb 
#  3>    9      15                " " " " "
#    5>             25  35  55 ..
#      7>                 49   ..
#
# End Maths
#
# Question is : do we tag browsed values ?
#            => no, better is to delete them
#               eh, same thing Bob..
#
# So what would represent each number 
#     and its status ?
#
# A 2 dimensions objet should be fine 
#  with widths square root as sides sizes
#  ideal should be a graphic representation..
#
# Actually I used 2 simple arrays,
#  1. for tagged numbers (not_Prime)
#  2. for Primes browsed since reaching
#     number entered as Input 
#  (the latter could have been a string though)
#
# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
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
	#         "Usage : $0 <Natural Number>"
	#
REGEX_PARAMS=\
'^[0-9][0-9]*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[0-9][0-9]*$'

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
	    printf2 "Usage : $0 <Natural Number>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0]} is Integer
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

# is_prime function :
#
# Very proud for this is an elegant
#  Solution !! ( only non-primes are tagged
#           in an array and we browse Primes !)
#
# => was initially a true/false Prime function
#    since the leap came with Primes array.
#
# tab indicing not primes at true
#
declare -a not_Prime=( ) Primes=( )
declare -i Current=1 n=0

# Current = Value of prime browse
#       n = Values of +prime non-primes tagging
#

is_prime () {

# nb : removing : #printf2 debug displays
#      improves very much performance
#      of this function (even if DEBUG=0!!)
#      ./sieve.sh 127127 >> takes 31s 584ms
#
#	printf2 "Current1 :" "$Current"
# Pretty same if infinite loop here (initially..)
  #
  while [[ "$Current" -lt "$1" ]]
  do
    # Starts with 1++ = 2 !
    # nb : not to put in append (yes is to cf nb2)
    #      because affectation is done 
    #      after when using ((var++)) !!
    #
    # nb2: forget nb (leap..)
    #((Current++)) > mess it all !!
    #              > keeping 1 as first Prime
    #                removed at the end...
    #
    Primes+=( "$((Current++))" )
	printf2 "Current2 :" "$Current"
#printf2 "Primes[@]" "${Primes[@]}"

#printf2 "Current while 1" "$Current"

    # Test if we tagged non-primes before
    #  means a value (true) 
    #    is at indice [nb] in array
    #
    while [ -n "${not_Prime[Current]}" ]
    do
	    # is tagged so jumping..
	    ((Current++))

#printf2 "Current while 2" "$Current"
    done
	
	[[ "$Current" -eq "$1" ]] \
     && Primes+=( "$((Current))" ) \
     && echo "${Primes[@]}" | cut -c 3- && return 0

# Initially func said true here
#   for is_prime <nb> question
#
#    && echo "true" && return 0

	n="$Current"
	while [[ "$n" -lt "$1" ]]
	do
		n+="$Current"
	    not_Prime[n]="${not_Prime[n]:=true}"

# Produces nice outputs ~ sieve :)
#
#printf2 "!not_Prime[@]" "${!not_Prime[@]}"

	done
#
# Initially stops if tagged entered number
#  as non prime..
	# if after non-primes tags, 
	#    we get our number 
	#       then it is not a Prime !!
	#
#	[[ "$n" -eq "$1" ]] \
#     && echo "${Primes[@]}" && return 1
#     && echo "false" && return 1
  done
#printf2 "Primes[@]\n" "${Primes[@]}" | cut -c 3-
echo "${Primes[@]}" | cut -c 3-
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
		is_prime "${Input[0]}"
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

