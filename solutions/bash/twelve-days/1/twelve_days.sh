#!/usr/bin/env bash
# DR - Ascen+28 - 2025
#

Source=$(cat <<END_SRC
On the <nth> day of Christmas my true love gave to me:<sth>
END_SRC
)

Source2=$(cat <<END_SRC2
first
second
third
fourth
fifth
sixth
seventh
eighth
ninth
tenth
eleventh
twelfth
END_SRC2
)

Source3=$(cat <<END_SRC3
 a Partridge in a Pear Tree.
 two Turtle Doves, and
 three French Hens,
 four Calling Birds,
 five Gold Rings,
 six Geese-a-Laying,
 seven Swans-a-Swimming,
 eight Maids-a-Milking,
 nine Ladies Dancing,
 ten Lords-a-Leaping,
 eleven Pipers Piping,
 twelve Drummers Drumming,
END_SRC3
)

declare -a Source2_array=( )
declare -a Source3_array=( )

IFS=$'\n'
for i in $Source2
do
	Source2_array+=( "$i" )
done

for i in $Source3
do
	Source3_array+=( "$i" )
done
IFS=' '

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

# Some checks
#
for i in {0..11}
do
	printf2 "Source2 :" "${Source2_array[i]}"
done

for i in {0..11}
do
	printf2 "Source3 :" "${Source3_array[i]}"
done

	printf2 "Source :" "$Source"

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
REGEX_PARAMS=\
'^[1-9][0-9]* [1-9][0-9]*$'
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[1-9][0-9]* [1-9][0-9]*$'

	#  
	#  [ Deep regex // tests.. ]
	#
	printf2 "${Input[@]}" | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "${Input[@]}" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
	
}

test_params () {

	# So called
	test_regex "$@"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! "${Input[@]}" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #
	    [ "$*" == "" ] && \
	    echo "Wrong void Input" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "Word, or componed word or name"
	    return 4
	else
	    #
            # Refining Regex Checks
	    #  ( here *all* goes through.. )
  	    #
	    [ "$*" == "" ] && \
	    echo "" && exit 0

	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_1day () {

     Tail=""
     day="$1"
     i="$((day - 1))"
     j="$i"
     while [[ "$i" -ge 0 ]]
     do
	 Tail+="${Source3_array[i]}"
	 ((i--))
     done

     printf2 "Tail :" "$Tail"

     Head="${Source//<nth>/"${Source2_array[j]}"}"
     
     printf2 "Head :" "$Head"

     echo "${Head//<sth>/"$Tail"}"

}

main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -a Input=( )

    store_Input "$@"

    # Test arguments
    test_params "$@"

    Return=$?

    # Process			  	# sed
    case "$Return" in             	# needed
	    0)                    	# xargs
		    for i in \       # or -s ' '
   		$(seq "$((Input[0]))" \
         	      "$((Input[1]))" | xargs )
		do
			printf2 "i :" "$i"
	 		mk_1day "$i"
		done
		    ;;
	    *)
		printf2 "Invalid Input Occurred"
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

