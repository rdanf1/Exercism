#!/usr/bin/env bash
# DR - Ascen+28 - 2025
#

Source_test=$(cat <<END_SRC 
["nail", "shoe", "horse", "rider", "message", "battle", "kingdom"]
END_SRC
)

Source=$(cat <<END_SRC
For want of a battle the kingdom was lost.
And all for the want of a nail.
END_SRC
)

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
	printf2 "@:" "$*"
	printf2 "1:" "$1"
	printf2 "2:" "$2"

	store_Input "$@"

	for i in "${!Input[@]}"
	do
		printf2 "Input i:" "${Input[$i]}"
	done

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	# 	Useless regex, ever.
REGEX_PARAMS=\
'^[ -~]*\( [ -~]*\)*$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^([!-~]* ?[!-~]*)*$'

#   '[ "<word1>", "<word2" ]' => useless
#'^\[ "[A-z]\+"\(, "[A-z]\+"\)* \]$'  => not @test

	#  [ Deep regex // tests.. ]
	#
	printf2 "$Input" | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ $Input =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
	
}

test_params () {

	# Warn
	#  no xargs : removes double quotes..
	#             from input and we keep them..
	#
	#Input="$(printf "%b" "$*" | xargs)"
	#Input="$(printf "%b" "$*")"
	#Input="$@"

	# So called
	test_regex "$@"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! $Input =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #
	    [ "$*" == "" ] && \
	    echo "true" && exit 0
	    

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

mk_proverb () {

    # Depends on nb of arguments
    # 1 single => Last phrase only
    #             with initial $1 argument
    # 2 or more=> write phrase with 1st - 2d
    #             then shift parameters ($2->$1,..)
    #             and call same function
    #             ( quite natural behavior here )
    # weirds: 1 space before "And.." in $Source
    #         2 need to add \n to separate lines
    #         from herescript.
    #
    case "$#" in
	    1)
		echo "$Source" | sed 's/ And/\nAnd/' \
		        | tail -n 1 \
			| sed "s/nail/${Input[0]}/"
		exit 0
		;;
	    *)
		echo "$Source" | sed 's/ And/\nAnd/' \
			| head -n 1 \
			| sed "s/battle/$1/" \
			| sed "s/kingdom/$2/"
		shift
		mk_proverb "$@"
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
	 	mk_proverb "${Input[@]}"
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

