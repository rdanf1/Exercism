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
	#  conforms with  triangle    size
	#         "Usage : $0 <type> <a b c>"
	#
REGEX_PARAM=\
'\(equilateral\|isosceles\|scalene\)'
REGEX_PARAMS=\
"^$REGEX_PARAM\( [0-9][0-9]*\(\.[0-9]\)\?\)\{3\}$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM1=\
'(equilateral|isosceles|scalene)'
REGEX_PARAM2=\
"^$REGEX_PARAM1( [0-9][0-9]*(.[0-9])?){3}$"

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

is_float () {
	echo "$1" | grep -q "\." \
     && return 0

	return 1
}

x10_float () {
	if is_float "$1" ;
	then
	    echo "$(( "$(echo "$1" \
                       | cut -d"." -f 1)" * 10 \
	+ "$(echo "$1" | cut -d"." -f 2)" ))"
	else
		echo "$(( "$1" * 10 ))"
	fi
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
	    printf2 "Usage : $0 <type> <a b c>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[1-3]} are Integers
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #

	   # If single scale float
	   #  x10 become integer
	   #
  	if ( is_float "${Input[1]}" \
  	 ||  is_float "${Input[2]}" \
	 ||  is_float "${Input[3]}" ) \
 	then
	    Input[1]=$(x10_float "${Input[1]}")
	    Input[2]=$(x10_float "${Input[2]}")
	    Input[3]=$(x10_float "${Input[3]}")
	fi

	printf2 "after x10 :" "${Input[@]}"

           # Any zero means not a triangle
  	  { [[ "${Input[1]}" -eq 0 ]] \
	 || [[ "${Input[2]}" -eq 0 ]] \
	 || [[ "${Input[3]}" -eq 0 ]] ;} \
         && echo "false" && exit 0	

	  # Check Triangle properties
	  sum12=$((Input[1] + Input[2]))
	  sum23=$((Input[2] + Input[3]))
	  sum13=$((Input[1] + Input[3]))

  	  { [[ "${Input[1]}" -gt "$sum23" ]] \
	 || [[ "${Input[2]}" -gt "$sum13" ]] \
	 || [[ "${Input[3]}" -gt "$sum12" ]] ;} \
         && echo "false" && exit 0	

	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

is_equ () {
 	if     [[ "$1" -eq "$2" ]] \
	    && [[ "$2" -eq "$3" ]]
	then
		return 0 
	fi
		return 1 
}

is_iso () {
 	if     [[ "$1" -eq "$2" ]] \
	    || [[ "$2" -eq "$3" ]] \
	    || [[ "$1" -eq "$3" ]]
	then
		return 0 
	fi
		return 1 
}

is_sca () {
 	if [[ "$1" -ne "$2" ]] \
	    && [[ "$2" -ne "$3" ]] \
	    && [[ "$1" -ne "$3" ]]
	then
		return 0
	fi
		return 1
}

is_what () {
	case "$1" in

		"equilateral")
			is_equ "$2" "$3" "$4" \
		     && echo "true" \
		     || echo "false"
			;;
		"isosceles")
			is_iso "$2" "$3" "$4" \
		     && echo "true" \
		     || echo "false"
			;;
		"scalene")
			is_sca "$2" "$3" "$4" \
		     && echo "true" \
		     || echo "false"
			;;
	esac
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
		is_what "${Input[@]}"
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

