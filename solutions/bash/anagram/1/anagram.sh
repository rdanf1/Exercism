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

# Functions

test_params () {

     # Empty chain
     #
       [ a"$*" == "a" ] \
     && echo "2 parameters needed" \
     &&	echo "Usage: $0 \"<anagram>\" \"<word word ..>\"" \
     && echo "exit 0" && exit 0

     # 2 parameters
     #
       [[ "$#" -lt "2" ]] \
     && echo "2 parameters needed" \
     &&	echo "Usage: $0 \"<anagram>\" \"<word word ..>\"" \
     && echo2 "exit 1" && exit 1

     # Input chain [unlimited]
     #   ( including à, è, .. )
     #
   #  REGEX_Words='^[À-ž]+( [À-ž]+)+$'
      REGEX_Words='^([[:alpha:]]+)( [[:alpha:]]+)+)$'
     REGEX_Words='^[A-z]+( [A-z]+)+$'
        

       [[ ! "$*" =~ $REGEX_Words ]] \
     && echo "Invalid input" \
     &&	echo "Usage: $0 \"<anagram>\" \"<word word ..>\"" \
     && echo2 "exit 2" && exit 2

     echo2 "Valid input"
}

up_to_low () {

	# Uppercase to Lowercase
	#
	echo $1 | tr '[:upper:]' '[:lower:]'
}

sort_Word () {
	   
	# Replacing each letter on a single line
	# then use sort, then replace them on a
	# single line with xargs, then remove spaces.
	#
	echo "$(up_to_low "$1")" \
		  | sed 's/./&\n/g' \
	          | sort | xargs    \
		  | sed 's/ //g'
}

main () {

    test_params "$@"

    anagram="$1"

    anagram_sorted="$(sort_Word "$1")"
    echo2 "anagram_sorted :" "$anagram_sorted"
    
    shift
    declare -a candidates=( $(echo "$*") ) \
	       candida_OK=( )

    echo2 "{candidates[@]} :" "${candidates[@]}" 

    for i in "${candidates[@]}"
    do
	 if [ "$(up_to_low "$i")"  != \
	      "$(up_to_low "$anagram")" ]
	 then
	    candidat_sorted="$(sort_Word "$i")"
	    echo2 "candidat_sorted :" "$candidat_sorted"

	    [ "$anagram_sorted" == "$candidat_sorted" ] \
	 && candida_OK+=( "$i" )
	    echo2 "candidat_OK :" "$candidat_OK" 
	 fi
    done

echo2 "#candidat_OK :" "${#candidat_OK[@]}" 

[[ ! "${#candida_OK[@]}" -eq "0" ]] \
 && echo  "${candida_OK[@]}"
 
    exit 0
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
exit 99

