#!/usr/bin/env bash
# DR - Ascension+44 - 2025
#
# Analyse
#
#       grouping in decimal units, then direct translation 
#       		    tens, 
#       		    hundreds, 
#       		    thousands
# ------|-----------vv--|-----------------vv---The tricky line!
#	I, II, III, IV, V, VI, VII, VIII, IX,  (think vertical)
#	X, XX, XXX, XL, L, LX, LXX, LXXX, XC, 
#	C, CC, CCC, CD, D, DC, DCC, DCCC, CM,
#	M, MM, MM, ..  MMMCMXCIX !       = 3999 
#  implicit rule : each set (*) for a single decimal digit (i) 
#	nb: if not (i) : MMMCMDDDCDCCCXCXXXIXVVVIVIII = 6251 !!!
#
#	33 patterns are needed => that's a lot !
#	   ( with 7 components I, V, X, L, C, D, M )
#
#	=> need construction rules.. => Cf: "The tricky line"
#
#	 basically it's a 5 oriented numeration system :
#
#	- 4 and 9 are special : formed by previous 
#	                               or previous previous
#	                               component plus next one !!
#	- Others equiv. decimal numbers are added by append scheme
#
#	Another approach, knowing this, is to 
#	decompose decimal number in the right
#	additions and substractions of roman numeral symbols.
#
#	or assume that OOOO = OP  ( With O,P,Q consecutive
#	     and that OPPPP = PQ    roman numeral symbols )
#	              four =  5 - 1
#	              nine = 10 - 1
#
#    or more precisely 4th = (-)<curr>      (+)<suiv>
#                      9th = (-)<prec_curr> (+)<suiv>
#
#    or :
#    roman symbols available : 1 5 10 50 100 500 1000
#    		    specials : 4 9 40 90 400 900
#    		    total    : 7x[1-3] + 6x[2] : 13 sets (*)
#    with implicit rule : each set represent one decimal digit !
#
#    => 
#        1. search of specials for units, tens, hundreds
#        2. append sums if necessary for others :
#            [1-3] : I,X,C,M   [5-8] V,L,D
#

# In another life..
#declare Romans="IVXLCDM"

#declare Romans_9=\
#"IXLD"
#"${Romans:0:1}""${Romans:2:1}""${Romans:4:1}""${Romans:6:1}"

# Practical / Actual
declare -a Units=\
( "" "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" )
declare -a Tens=\
( "" "X" "XX" "XXX" "XL" "L" "LX" "LXX" "LXXX" "XC" )
declare -a Hundreds=\
( "" "C" "CC" "CCC" "CD" "D" "DC" "DCC" "DCCC" "CM" )
declare -a Thousands=\
( "" "M" "MM" "MMM" )

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
	#   "Usage : $0 <integer>"
	#
REGEX_PARAMS=\
'^[0-9]\+$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[0-9]+$'

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
	    echo "Usage : $0 <integer>"
	    return 1
	else
	#
	# From here ${Input[0]} is 1 [A-Z] letter
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    [[ "$Input2" -gt 3999 ]] \
	 && echo "Usage : $0 <integer>" \
	 && return 2
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}


mk_roman () {

	result=""
	level=0
	rev_Input="$(echo "$Input2" | rev)"

	while [[ "${#rev_Input}" -ne 0 ]]
	do
	    ((level++))
	    case "$level" in
		1)
		result="${Units["${rev_Input:0:1}"]}"
		;;
		2)
		result="${Tens["${rev_Input:0:1}"]}""$result"
		;;
		3)
		result="${Hundreds["${rev_Input:0:1}"]}""$result"
		;;
		4)
		result="${Thousands["${rev_Input:0:1}"]}""$result"
		;;
	    esac
	    printf2 "result" "$result"
	    printf2 "rev_Input" "$rev_Input"
	    rev_Input="${rev_Input:1}"
    	done
	echo "$result"
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
		mk_roman "$@"
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

