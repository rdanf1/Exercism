#!/usr/bin/env bash
# DR - Ascension+48 - 2025
#
# Analyse

IFS=$'\n'

Source1=$(cat <<End_Src1
I know an old lady who swallowed a 1.
End_Src1
)
Source2=$(cat <<End_Src2
I don't know why she swallowed the fly. Perhaps she'll die.
End_Src2
)
Source3=$(cat <<End_Src3
She swallowed the 2 to catch the 1.
End_Src3
)
Source4=$(cat <<End_Src4

It wriggled and jiggled and tickled inside her.
How absurd to swallow a bird!
Imagine that, to swallow a cat!
What a hog, to swallow a dog!
Just opened her throat and swallowed a goat!
I don't know how she swallowed a cow!
She's dead, of course!
End_Src4
)
Source5=$(cat <<End_Src5
that wriggled and jiggled and tickled inside her.
End_Src5
)
# [0] is empty "" => indice start at 1, ends at 8
declare -a Srce_array1=( \
"" "fly" "spider" "bird" "cat" "dog" "goat" "cow" "horse" )



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
	#   "Usage : $0 <some text>"
	#
REGEX_PARAMS=\
'^[1-8] [1-8]$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[1-8] [1-8]$'

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
	    [[ "$#" -ne 2 ]] \
	 && echo "2 arguments expected" && exit 1

	    # Whatever ( said bob.. )
    	    echo "Usage : $0 <1st verse> <last verse>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here Input2 is whatever was filtered 
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    [[ "$1" -gt "$2" ]] \
	 && echo "Start must be less than or equal to End" \
	 && exit 2
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_chain () {
	printf2 "Srce_array1[$1] :" "${Srce_array1[$1]}"
	#echo "$Source1" | sed "s/1/${Srce_array1[$1]}/"
	# As suggesteed..
	echo "${Source1//1/"${Srce_array1[$1]}"}"
	case "$1" in

	   1) echo "$Source2"
		   ;;
	   8) echo "$Source4" | tail -n 1
		   ;;
#  	   2) echo "$(echo "$Source4" | head -n 1)"
# echo "$Source3" | sed "s/<2>/${Srce_array1[$1]}" \
#	 	 | sed "s/<1>/${Srce_array1[$(($1 - 1))]}"
# 	      echo $Source2
#	      ;;
	   *) declare -i i="$(($1 - 1))"
	      echo "$Source4" | head -n "$((i + 1))" \
			      | tail -n 1 

	   while [[ "$i" -ne 0 ]]
	   do
 echo "$Source3" | sed "s/2/${Srce_array1[$((i + 1))]}/" \
	 	 | sed "s/1/${Srce_array1[i]}/" \
		 | sed "s/spider\./spider $Source5/"
 	   ((i--))
	   done

 	      echo "$Source2"
	      #mk_chain "$(($1 - 1))"
	      ;;
	esac

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
		for i in $(seq "$1" "$2")
		do
			mk_chain "$i"
			[[ "$i" -ne "$2" ]] && printf '\n'
		done
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

