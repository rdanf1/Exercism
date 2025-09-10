#!/usr/bin/env bash
# DR - Ascen+42 - 2025
#
# Maths
#      quite straight forward :
#       1. strip hyphens if any
#       2. for each char/digit 
#           add its proper position value
#       3. check validity mod 11
# End Maths
#

# Debug mode [ mainly  for echoes from 
#             'printf2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0


# Functions

# Debugging printf
#
#    Usage: printf2 "<values..>"
#
printf2 () {

	if [[ "$DEBUG" -gt "0" ]] 
	then
		printf '"%s"\n' "$*"
	fi
	# Always true
	return 0	
}

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

        # for grep test :   escapes 
	#          only : & quotes in grep arg
	#
	# nb: dunno how to manage hyphens & grep..
	#
REGEX_PARAMS=\
'^\([0-9]\|X\|\-\)\+$'

	# Same as above limited to lowers or digits
	#                       or apostrophes
	#                       or spaces
	#
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#  conforms with : 
	#              ISBN NUMBER
	# Usage : $0 <N-NNN-NNNNN-N> (N ∈ [0-9,X])
	#
REGEX_PARAM2=\
'^[0-9]+( [0-9]*)*$'
# was all ascii
#'^[ -~]*$'

	#  [ Deep regex // tests.. ]
	#
	printf2 "${Input[*]}" \
      | grep -q "$REGEX_PARAMS" 2>/dev/null \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

     #
     # 
     #
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
	    echo "false" && exit 0

	    # Usage response (if any required, not here..)
	    #
echo "Usage: $0 <N-NNN-NNNNN-(N/'X')> (N ∈ [0-9])"
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
	[ "$Input2" == "0" ] \
     && echo "false" && exit 0
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

is_luhn1 () {

	luhn="${Input2// /}"
	declare -i pos=-2 sum=0 
	
	while [[ "$pos" -lt "${#luhn}" ]]
	do
		pos=$((pos + 2))
		digit="${luhn:"$pos":1}"
			

		digit=$((digit * 2))
		if [[ "$digit" -gt 9 ]]
		then 
		    sum+="$((digit - 9))"
	        else
		    sum+="$digit"
		fi

		# adding next digit "as is" (step is +2)
		sum+="${luhn:$((pos + 1)):1}"

		printf2 "sum :" "$sum"
	done
	return "$((sum % 10))"
}

is_luhn2 () {

	luhn="${Input2// /}"
	declare -i pos=-1 sum=0 digit=0 
	
	while [[ "$pos" -lt "${#luhn}" ]]
	do
		pos=$((pos + 2))
		digit="${luhn:"$pos":1}"
			

		digit=$((digit * 2))
		if [[ "$digit" -gt 9 ]]
		then 
		    sum+="$((digit - 9))"
	        else
		    sum+="$digit"
		fi

		# adding previous digit "as is" (step is +2)
		sum+="${luhn:$((pos - 1)):1}"

		printf2 "sum :" "$sum"
	done
	return "$((sum % 10))"
}


main () {
	# Filled with store_Input()
	# called in test_regex()
	#
	#   ( nearly the very same as "$@" )
	#
	declare -a Input=( )
	# Simple string version of Input
	declare Input2=""

	test_params "$@"
	Return=$?

	# Process
	#
	case "$Return" in
		0)
		    if is_luhn1 "$@" \
		    || is_luhn2 "$@" 
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
}



# Call main with all of the positional arguments
   main "$@"

