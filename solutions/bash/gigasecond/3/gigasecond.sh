#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#
# Maths
#      quite straight forward :
#       1. get epoch of input
#       2. add a million seconds (or any amount of seconds
#                                 2d undocumented argument)
#       3. output new epoch with date format
# End Maths
#

#
# epochs in sec since 01/01/1970 01:00:00
#
#  offset choosen somewhere in between (or 3/4) :
#                   25/12/1997 00:00:00
#
declare -r -i TIME_OFFSET="$((60*60*24*365*28-60*60))"


# Debug mode [ mainly  for echoes from 
#             'printf2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0


# to check
#    and for further mesurements
#
#date --date="@$((60*60*24*365*28-60*60))"

Clock1 () {

	printf2 "$*"
	printf2 "$1" "$2" "$3" "$4"
	
	declare -i Hour=0 \
		   Min=0  \
		   Min_PM=0 \

		   ###########>>>>>> +1 hour on the
	           #####                exercism website
	Hour="$(( ${1}*60*60 + 1*60*60))"
	Min="$(( ${2}*60 ))"

	# Plus or Minus minutes
	Min_PM="$(( ${3}${4}*60 ))"

	Clock=$(( $TIME_OFFSET + $Hour + $Min \
			       + $Min_PM ))

	# with epoch
	date "+%H:%M" --date="@$((Clock))"

	# test format ok
	#
	date "+%Y-%m-%dT%H:%M:%S" -d "2046-10-02T23:46:40"
	# Epoch initial 0 gives 1970-01-01T01:00:00
	date "+%Y-%m-%dT%H:%M:%S" -d "@0"
	# Getting epoch from a date
	date "+%s" "2046-10-02T23:46:40"
}

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

        # for grep :   escapes 
	#            & quotes in grep arg
	#
	#  conforms with :        optional >--------v
	# Usage : $0 <YYYY-MM-DD>[T<hh:mm:ss>] [+seconds]
	#
REGEX_PARAMS=\
'^[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9]\(T[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\)\?\( [0-9]*\)\?$'

	# Same as above limited to lowers or digits
	#                       or apostrophes
	#                       or spaces
	#
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[0-9][0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9](T[0-2][0-9]:[0-5][0-9]:[0-5][0-9])?( [0-9]*)?$'
#'^[0-9]*( [0-9]*)*$'
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
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

gigasec () {
	datei="$1"
	jump="$2"
	jump="${jump:=1000000000}"
	printf2 "jump :" "$jump"
	# +1 hour for @test !
 	epoch="$(date "+%s" -d "$datei")"
	printf2 "epoch1 :" "$epoch"

	# When short positive (>1970-01-01)
	#   +1h
	#
#	[[ $epoch -ge 0 ]] \
#     && [[ "${#datei}" -eq 10 ]] \
#     && jump=$((jump + 60*60))

	# When long format -1h
	#
#        [[ "${#datei}" -gt 10 ]] \
#     && jump=$((jump - 60*60))

	epoch=$((epoch + jump))
	printf2 "epoch2 :" "$epoch"

	date "+%Y-%m-%dT%H:%M:%S" -d "@$epoch"
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
		    gigasec "$@"
                    ;;
                *)
		    printf2 "An Invalid Input Occurred"
		    exit 1
		    ;;
        esac
}



# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99
#

