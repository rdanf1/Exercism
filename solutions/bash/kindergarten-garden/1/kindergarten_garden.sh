#!/usr/bin/env bash
# DR - Ascen+40 - 2025
#
# Maths
#        Strait-forward :
#        - Format output as 3 "flat" args (Input2)
#        - Pick 4 letters of rank of child alphabetically
#        - For each letter Output full names of plants
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

Source_names="$(cat <<END_SRC
Alice, Bob, Charlie, David, Eve, Fred, Ginny, Harriet, Ileana, Joseph, Kincaid, Larry
END_SRC
)"

declare -A Ranks=( )
j=0
for i in ${Source_names//,/}
do
	Ranks+=( ["$i"]="$j" )
	((j++))
done
printf2 "@ Names :" "${Ranks[@]}"
printf2 "! Names :" "${!Ranks[@]}"
printf2 "Ginny Rank :" "${Ranks["Ginny"]}"

plants="Grass Clover Radishes Violets"
declare -A Plants=( )
for i in $plants
do
	Plants+=( ["${i:0:1}"]="${i@L}" )
done
printf2 "@Plants :" "${Plants[@]}"
printf2 "!Plants :" "${!Plants[@]}"
printf2 "R Plant :" "${Plants[R]}"


# Functions

store_Input () {

	while [[ "$#" -gt 0 ]]
	do
	    Input+=( "$1" )
	    Input2+=" $1"
	    printf2 "Input  while :" "${Input[@]}"
	    shift
	done
	    # Remove 1st char (=space)
	    Input2="${Input2:1}"
	    # Input2 is linear 
	    #    (=> replace newlines with spaces !)
	    Input2="${Input2//$'\n'/ }"
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
	#  conforms with (Flat Input2) :
	#
        # "Usage: $0 <1st_row> <2d_row> <Child>"
	#
REGEX_PARAMS=\
'^\(C\|G\|R\|V\)\{2,24\} \(C\|G\|R\|V\)\{2,24\} [A-Z][a-z]*$'

	# Same as above limited to lowers or digits
	#                       or apostrophes
	#                       or spaces
	#
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^(C|G|R|V){2,24} (C|G|R|V){2,24} [A-Z][a-z]*$'
#'^[ -~]*$'

	#  [ Deep regex // tests.. ]
	#
	printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

     # If this don't pass means we've forgotten
     #   some "specials" ascii removing above (sed ..)
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

	    # Whatever ( said bob.. )
	    # nb : \n display -v--vv without <newline> !
	    #
printf "Usage: %s $'<1st_row>"'\'"\n<2d_row>' <child>\n" "$0"
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

is_garden () {
	declare -a Final_result=( )
	row_1="$1"
	row_2="$2"
	# 1st indice of row is twice rank of child
	rank="$((Ranks["$3"] * 2))"

	# 
	# We take 2 chars for each row 
	#
        rank2=2

	result1=${row_1:"$rank":"$rank2"}
	result2=${row_2:"$rank":"$rank2"}
	result="$result1""$result2"

	printf2 "rank :" "$rank"
	printf2 "rank2 :" "$rank2"
	printf2 "row_1 :" "$row_1"
	printf2 "row_2 :" "$row_2"
	printf2 "result1 :" "$result1"
	printf2 "result2 :" "$result2"
	printf2 "result :" "$result"

	while [[ "${#result}" -gt 0 ]]
	do
		Final_result+=( "${Plants["${result:0:1}"]}" )
		result="${result:1}"
	done
	echo "${Final_result[@]}"
}



main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )
    
    # Simple string version of Input
    declare Input2=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		is_garden $Input2
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

