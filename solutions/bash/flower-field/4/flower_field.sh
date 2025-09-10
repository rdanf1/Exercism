#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Analyse
#
#	0. normalization  : replace garden spaces with 0
#	             ( to keep it numeric ) and * with 9
#
# 	1. browse scheme  : when on '9' value, do +1
# 	                    to all existing adjacent values
# 	                    containing 0 or a number <> 9
#
# 	2. restitution    : replace all 0 with spaces
# 	                            all 9 with *
# REM : 
#    Input2 (flat) and Input[] (2D) are inputs as is
#                               ( same as initially given )
#
#               additions	Relative coordinates where
#               to perform	 +1 is applied (if existing!)
#
#		    +1+1+1  	(-1:-1)(-1: 0)(-1: 1)
#                   +1 9+1	( 0:-1)  0: 0 ( 0: 1)
#		    +1+1+1	( 1:-1)( 1: 0)( 1: 1)
# 	          
#

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

	# same as @tests
	#
    	local IFS=$'\n'

	while [[ "$#" -gt 0 ]]
	do
	    Input+=( "$1" )
	    Input2+="$1"
	    # Input2 without spaces..
	    #Input2+=" $1"
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
	    #Input2="${Input2:1}"
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
'^\( \|\*\)*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^( |\*)*$'

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
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_garden () {

	declare -A Input4=( )
	declare -a Flowers=( )
	Input3="$Input2"
	declare -i cols="${#Input[0]}" \
		   rows="${#Input[@]}"
	printf2 "cols :" "$cols"
	printf2 "rows :" "$rows"

	for i in $(seq "$rows")
	do
	    for j in $(seq "$cols")
	    do
		if [ "${Input3:0:1}" == " " ]
		then
		    #printf '0'
		    Input4+=( ["$i":"$j"]=0 )
	    	else
		    #printf "%s" "${Input3:0:1}"
		    Input4+=( ["$i":"$j"]=9 )
		    Flowers+=( "$i:$j" )
		fi
		Input3="${Input3:1}"
	    done
	    #printf '\n'
	done
	for i in $(seq "$rows")
	do
	    for j in $(seq "$cols")
	    do
		if [[ "${Input4[$i:$j]}" -eq 9 ]]
		then
		    # when a flower, turning around..
		    #
		    for k in $(seq $((i - 1)) $((i + 1)))
		    do
		        for l in $(seq $((j - 1)) $((j + 1)))
			do
			#  Empty means non-existent adjacent
			#  or if already a flower : do nothg
			#  else increment adjacent k:l
			#
			[ "${Input4[$k:$l]}" != "" ] \
		     && [[ "${Input4[$k:$l]}" -ne 9 ]] \
		     && (( Input4["$k:$l"]++ )) \
		&& printf2 "Input4[$k:$l]" "${Input4[$k:$l]}"
			done
		    done
		fi
	    done
	    #printf '\n'
	done
	for i in $(seq "$rows")
	do
	    for j in $(seq "$cols")
	    do
		printf "%i" "${Input4[$i:$j]}" \
	               | sed 's/0/ /g' | sed 's/9/\*/g'
	    done
	    printf '\n'
	done

	printf2 "flowers :" "${Flowers[@]}"
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
		mk_garden "$@"
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

