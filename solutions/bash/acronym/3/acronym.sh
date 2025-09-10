#!/usr/bin/env bash
# DR - Ascen+16 - 2025
#

# Debug mode [ mainly  for echoes from 
#             'echo2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
#    Usage: echo2 "<echo param>" "<values..>"
#
echo2 () {
	# TODO : Manage *any* echo parameters
	if [[ "$DEBUG" -gt "0" ]] 
	then
	   [ "$1" != "-n" ] && echo "$*"
	   [ "$1" == "-n" ] && shift && echo -n "$*"
	fi
	# Always true
	return 0	
}

# Better practice ?
# 
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		Format="$1"
		shift
		Vars="$*"
		#Vars="$@"
		printf "$Format" "$Vars"
	fi
}

# Functions

test_params () {

     # Empty chain ( wrong test if input with "*"
     #               tested with "$*" => Empty 1/2
     #               With "One * Word" test.. )
     #
     #   [ a"$*" == "a" ] \
     [ "a""$@" == "a" ] \
     && echo "N parameters needed" \
     && echo2 "\*" "$*" \
     && echo "Usage: $0 \"<Prase to Acronymism>\"" \
     && echo "exit 0" && exit 0

     printf2 "\$@ is : '%s'\n" "$@"
     printf2 "\$* is : '%q'\n" "$*"

     # 2 parameters
     #
       [[ "$#" -lt "1" ]] \
     && echo "At least 1 parameters needed" \
     &&	echo "Usage: $0 \"<Prase to Acronymism>\"" \
     && echo2 "exit 1" && exit 1

     # 4 passing @test or 2..
     #
     # Remove punct and single caret ' - '
     #
     Input=$(echo "$@" | sed "s/\(_\|*\|%\|'\)//g" \
	     	       | sed 's/ - / /g'           \
	     	       | sed 's/-/ /g'             \
	     	       | tr  '[:punct:]' ' '       \
	     	       | tr -s '.' ' ')

     #echo2   "Input 1:"      "$Input"
     printf2 "Input 1: %s\n" "$Input"

     # Input chain [unlimited]
     #   ( including à, è, .. )
     #
     # Didn't include greek though..
     #
     # No accentuations allowed for 1st character
     #  of a word (dunno how to capitalise it!)
     #
     REG_Chr1='[A-z]'
     REG_Chr2='[À-ž]|[A-z]'
     REGEX_Word="($REG_Chr1)($REG_Chr2|-)*"
     REGEX_Words="^$REGEX_Word( $REGEX_Word)*$"

     echo2 "REGEX_Words :" "$REGEX_Words"

       [[ ! "$Input" =~ $REGEX_Words ]] \
     && echo "Invalid input" \
     &&	echo "Usage: $0 \"<Prase to Acronymism>\"" \
     && echo2 "exit 2" && exit 2

     # Caret between 2 words made space..
     #
     Input="$(echo "$Input" | tr '-' ' ')"
     echo2 "Input 2 :" "$Input"

     echo2 "Valid input"
}

low_to_up () {

	# Lowercase to Uppercase 
	#
	echo -n "$1" | tr '[:lower:]' '[:upper:]'
}

main () {

    Input=""

    test_params "$@"

    declare -a acronym=( $Input )

    echo2 "{acronym[@]} :" "${acronym[@]}" 

    for i in "${acronym[@]}"
    do
	    # nb : can do it at once with printf
	    #    (no cut required)
	    #
	    low_to_up "$(printf "%c" "$i")"
    done

    printf "\n"

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
# test sample !
# $ ./acronym.sh d-ëkk iî-k gà
#

