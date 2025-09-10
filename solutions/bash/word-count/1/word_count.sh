#!/usr/bin/env bash
# DR - Ascen+40 - 2025
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

	# Transforms Input2 to flat lower ascii
	#
	#   ( exept 1st sed, sed follows ascii order )
	#
	        Input2="$(echo "$Input2" | \
			    tr '\n' ' '  | \
			    tr '"' ' '  | \
			    tr '.' ' '  | \
			    tr '[:upper:]' '[:lower:]' \
		          | sed 's/\\.\|:\|,\|\?\|\!/ /g' \
		          | sed 's/[!-&]/ /g' \
		          | sed 's/[(-+]/ /g' \
		          | sed 's/[:-@]/ /g' \
		          | sed 's/[\[-\^]/ /g' \
		          | sed 's/`/ /g' \
		          | sed 's/[{-~]/ /g' \
		          | sed "s/ '/ /g" \
		          | sed "s/^'/ /g" \
		          | sed "s/'$/ /g" \
		          | sed "s/ '/ /g" \
		          | sed "s/' / /g" \
			  | tr -s ' ')"

		printf2 "Input2 2:" "$Input2"


        # for grep :   escapes 
	#            & quotes in grep arg
	#
	#  conforms with :
	# Usage : $0 <Any ascii chars>
	#
REGEX_PARAMS=\
'^[ -~]*$'

	# Same as above limited to lowers or digits
	#                       or apostrophes
	#                       or spaces
	#
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[ -~]*$'
#"^([a-z]|'|[0-9]| )*$"

	#  [ Deep regex // tests.. ]
	#
	printf2 "${Input[*]}" \
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
echo "Usage: $0 <base1> \".. <digit1> <digit0>\" <base2>"
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

wrds_count () {

	# Associative array !
	#
	declare -A Wrds_Array=( )

	# Input2 contains lower words
	#
	for i in $Input2
	do
	    # One line result !
	    #  ( initialize to 0 then +1 or +1 )
	    #
	    Wrds_Array[$i]=$(("${Wrds_Array[$i]:=0}" + 1))
	done

	# Result
	for i in "${!Wrds_Array[@]}"
	do
	    echo "$i: ${Wrds_Array["$i"]}"
	done
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
		wrds_count "$@"
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

