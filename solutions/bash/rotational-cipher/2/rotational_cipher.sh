#!/usr/bin/env bash
# DR - Ascen+28 - 2025
#

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

Source=$(cat <<END_SRC
abcdefghijklmnopqrstuvwxyz
END_SRC
)

# nb : Dont work
#Source={a..z}

# Same as above Source <<
#   ( for fixed sequences only 
#       {<fixed1>..<fixed2>} )
#
# We need a string and 2 arrays

# Whole alphabet (lowcase)
Source=""

# Array :             0->a, 1->b, ...
#  With indice get letter (for display)
#
declare -a Source_Array=( )

# Associative array : a->0, b->1, ...
#  Get indice from letter (for rot)
#
declare -A Source_Assoc=( )

j=0
for i in {a..z}
do
	Source+="$i"

	Source_Array[j]="$i"

	Source_Assoc+=( ["$i"]="$j" )
	((j++))
done

#echo "Source : $Source" && exit

# Whole alphabet (Uppercase)
Source_CAPS=${Source@U}
printf2 "Source_CAPS :" "$Source_CAPS"

# ^^ Done above in {a-z} sequence ^^
# Source_Array=($(echo "$Source" | sed 's/./& /g'))
#for i in ${Source_Array[@]}
#do
#	((j++))
#	Source_Assoc+=( ["$i"]="$j" )
#done

printf2 "Source_Array :" "${Source_Array[@]}"
printf2 "Source_Assoc :" "${Source_Assoc[@]}"

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
	#   Any sentence (any punctuation)
	#
REGEX_PARAMS=\
'^[A-z]\+\([ -~][A-z]*\)*\([ -~][0-9][0-9]*\)$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[A-z]+([ -~][A-z]*)*([ -~][0-9][0-9]*)$'

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
	    [ "$*" == "" ] && \
	    echo "" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "Usage : $0 \"<sentence> <ROT>\""
	    return 1
	else
	    #
            # Refining Regex Checks
	    #  ( here *all* goes through.. )
  	    
	    # Nothing
	    [ "$*" == "" ] && \
	    echo "" && exit 0

       # Retrieve last parameter
       #  (even if included within "")
       #
       LAST_IND="$((${#Input[@]} - 1))"
       LAST_ARG="${Input[LAST_IND]}"
       ROT="$(echo "$LAST_ARG" | xargs \
	    | rev | cut -d' ' -f 1 | rev)"
       
       # Last arg without ROT nb
       #
       LAST_ARG="$(echo "$LAST_ARG" | xargs \
	    | rev | cut -d' ' -f 2- | rev)"

       # It happens when last arg is ROT
       #   not to be printed..
       #
       if [ "$LAST_ARG" != "$ROT" ]
       then
	   Input[LAST_IND]="$LAST_ARG"
       else
	   Input[LAST_IND]=""
       fi

       # Using a case "or"
       #   for displaying "as is" the Input
       #
       case "$ROT" in
	       "0" | "26")

		# nb: no quotes here !
		#  as usual when using sed..
		#
		# nb: {0..$Anyvar} fails !
		#         ^ must use fixed values
		#
		for i in $(seq 0 "$LAST_IND")
	  	do
	            printf "%s" "${Input[i]}"
          	done

	 	printf "\n"
	        exit 0
	  	    ;;
       esac

       # Some debug prints
       #
       printf2 "ROT =" "$ROT"
       printf2 "LAST_ARG=" "$LAST_ARG"
       printf2 "Input[LAST_IND] :" \
	     "${Input[LAST_IND]}"

	# Checking ROT
	#
	[[ "$ROT" -gt 26 ]] \
     && echo "wrong ROT" && return 2

	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

# is_CAP and is_LOW functions
# quiet Fixed grep :
#
#  (-F prevents ie '.' expension)
#  (-q prevents output)
#
is_CAP () {
	echo "$Source_CAPS" | grep -qF "$1"
}

is_LOW () {
	echo "$Source" | grep -qF "$1"
}

print_Low () {

    ind="$(( (Source_Assoc["$1"] + "$ROT") % 26 ))"
    printf "%s" "${Source_Array[ind]}"
}

print_Cap () {
    to_print="$(print_Low "${1@L}")"
    printf "%s" "${to_print@U}"
}

mk_cypher () {

    printf2 "making cypher.."

    # Browse each argument char by char !
    #
    for i in $(seq 0 "$LAST_IND")
    do
	while [[ "${#Input[i]}" -ne 0 ]]
	do
	    CHAR="${Input[i]:0:1}"
	    if is_LOW "$CHAR" ;
	    then
		printf2 "is Low :" "$CHAR"
		print_Low "$CHAR"
	    else
		if is_CAP "$CHAR" ;
		then
		    printf2 "is Cap :" "$CHAR"
		    print_Cap "$CHAR"
		else
		    # Print unchanged
		    printf2 "Other :" "$CHAR"
		    printf "%s" "$CHAR"
		fi
	    fi
	    Input[i]="${Input[i]:1}"
	done
    done
    printf "\n"
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
	 	mk_cypher
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

