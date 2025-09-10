#!/usr/bin/env bash
# DR - Ascen+31 - 2025
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

# See above
printf2 "TIME_OFFSET :" \
"$(date "+%Y:%m:%d" \
--date="@$((TIME_OFFSET + 1000000000))")"

Source=$(cat <<END_SRC
| Planet  | Orbital period in Earth Years |
| ------- | ----------------------------- |
| Mercury | 0.2408467                     |
| Venus   | 0.61519726                    |
| Earth   | 1.0                           |
| Mars    | 1.8808158                     |
| Jupiter | 11.862615                     |
| Saturn  | 29.447498                     |
| Uranus  | 84.016846                     |
| Neptune | 164.79132                     |
END_SRC
)

# 2 values at once for 
#   associative array
#  (this was the hard/longer part)
#
# nb: Ok *only* like this ! 
#     - IFS, cut -d, tr -d, etc..
#
declare -A Planets
IFS='|'
    while read -r j k 
    do
	printf2 "j :" "$j"
	printf2 "k :" "$k"
	Planets+=( ["$j"]="$k" )
    done < <(echo "$Source" | tail -n 8 \
	        | tr -d ' ' | cut -d'|' -f 2-3)
IFS=' '
printf2 "@Planets :" "${Planets[@]}"
printf2 "!Planets :" "${!Planets[@]}"

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

	printf2 "@:" "$@"
	printf2 "*:" "$*"
	printf2 "1:" "$1"
	printf2 "2:" "$2"

	for i in "${!Input[@]}"
	do
		printf2 "Input i:" "${Input[$i]}"
	done

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with  
	#         "Usage : $0 <Planet> <secs>"
	#
REGEX_PARAM=\
"$(echo "${!Planets[@]}" | sed 's/ /\\|/g')"
printf2 "REGEX_PARAM :" "$REGEX_PARAM"
REGEX_PARAMS=\
"^\($REGEX_PARAM\) [0-9][0-9]*$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
# Variable with available planets
# for using in next regex variable
#  <planet1>|<planet2>|..
REGEX_PARAM1=\
"$(echo "${!Planets[@]}" | tr ' ' '|')"
printf2 "REGEX_PARAM1 :" "$REGEX_PARAM1"

REGEX_PARAM2=\
"^($REGEX_PARAM1) [0-9][0-9]*$"

	#  [ Deep regex // tests.. ]
	#
	printf2 "${Input[@]}" | grep -q "$REGEX_PARAMS" \
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
	    printf2 "Usage : $0 <Planet> <secs>"
	    echo "not a planet"
	    return 1
	else
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
  	    
       # Retrieve last parameter
       #  (even if included within "")
       #
       LAST_IND="$((${#Input[@]} - 1))"
       LAST_ARG="${Input[LAST_IND]}"
       Seconds="$(echo "$LAST_ARG" | xargs \
	    | rev | cut -d' ' -f 1 | rev)"
       
       # Last arg without Seconds
       #    ( is 1st arg too here cf regex )
       #
       LAST_ARG="$(echo "$LAST_ARG" | xargs \
	    | rev | cut -d' ' -f 2- | rev)"

       # It happens when last arg is :
       #   "Seconds" : no need to be kept
       #
       if [ "$LAST_ARG" != "$Seconds" ]
       then
	   Input[LAST_IND]="$LAST_ARG"
       else
	   Input[LAST_IND]=""
       fi
       #
       # From here ${Input[0]} is Planet


       # Some debug prints
       #
       printf2 "Seconds =" "$Seconds"
       printf2 "LAST_ARG=" "$LAST_ARG"
       printf2 "Input[LAST_IND] :" \
	     "${Input[LAST_IND]}"
       printf2 "Input[0] :" \
	     "${Input[0]}"

	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

# Sample with bc (21600 sec = 0.25 day because, 
#                 1 year approx. = 365.25 )
#
# printf float %.2f used for rounding
#                   and  for 0.dd values
#   ( bc do ".dd" output not 0.dd and 
#     bc cut decimals : no rounding ie 1.657 => 1.65 )
#  
# All we need after this is cutting last decimal
#
# bc <<<"scale=3;1000000000/(60*60*24*365+21600)+0.005/1"
# 31.688

is_age () {

    printf2 "Calculate space age.."
    printf2 "1 :" "$1"
    printf2 "2 :" "$2"

    printf "%.2f\n" \
"$(bc <<<"scale=3;\
($2/($1*(60*60*24*365+21600)))")" 

}

# ^ See above ^ is_age function
# Without printf float ( 0.dd = ko! )
# Initial method (+0.005 forced rounding
#                  and cut last decimal..)
#("$2"/("$1"*(60*60*24*365+21600))+0.005/1)" \
#	| rev | cut -c 2- | rev)"

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
	       is_age "${Planets["${Input[0]}"]}" \
		      "$Seconds"
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

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99
#

