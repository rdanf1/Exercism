#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Analyse
#		Mainly substitutions issues
#		Can we do them *all* at once ?!
#
#		=> regex transcriptions of 4 rules
#		   is the beginning, and with those
#		   we can see that some rules must 
#		   apply before others :
#		   1. rule1
#		   2. rule3 (or 4)
#		   3. rule4 (or 3)
#		   4. rule2
#
#		=> then it's a job for 
#		   sed command with extended regex option
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
	#   "Usage : $0 <pascal's triangle level> (N)"
	#
REGEX_PARAMS=\
'^[a-z,\*]\+\( [a-z]\+\)*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[a-z,\*]+( [a-z]+)*$'

# Those are for grep ( many escaped ! )
RULE1=\
'^\(a\|e\|i\|o\|u\|xr\|yt\)[a-z,\*]\+$'
RULE2=\
'^[^a,e,i,o,u][a-z,\*]*$'
RULE3=\
'^[^a,e,i,o,u]*qu[a-z,\*]*$'
RULE4=\
'^[^a,e,i,o,u]\+y[a-z,\*]*$'

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
    	    echo "Usage : $0 <pascal's triangle level> (N)"
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

is_rule1 () {
	echo "$1" | grep -q "$RULE1"
	return "$?" 
}
is_rule2 () {
	echo "$1" | grep -q "$RULE2"
	return "$?" 
}
is_rule3 () {
	echo "$1" | grep -q "$RULE3"
	return "$?" 
}
is_rule4 () {
	echo "$1" | grep -q "$RULE4"
	return "$?" 
}

mk_piglat () {

	j=0
	# nb0 : @Q=quoted (**)
	#
	for i in ${Input2@Q}
	do
		# nb0 : removing quotes (**)
		#
		i="${i//\'/}"
		
		((j++))
		printf2 "rule0 :" "$i"
		if is_rule1 "$i" 
		then
		    printf2 "rule1 :" "$i"
		    printf '%say' "$i"
		else
		    if is_rule3 "$i"
		    then
		        printf2 "rule3 :" "$i"
			printf %s \
			       "$(printf %s "$i" \
			       | sed -E 's/(.*qu)(.*)/\2\1ay/')"
		    else 
		        if is_rule4 "$i"
		        then
		            printf2 "rule4 :" "$i"
			    printf %s \
			       "$(printf %s "$i" \
			       | sed -E 's/(.*)y(.*)/y\2\1ay/')"
		        else
		            while is_rule2 "$i" 
		            do
		                printf2 "rule2 :" "$i"
			        i="${i:1}""${i:0:1}"
		            done
			    # was rule2 !
			    printf '%say' "$i"
		        fi
		    fi
		fi

	    # should not use Input but Input2 though..
	    #
	    [[ "$j" -lt "${#Input[@]}" ]] \
	    && printf " "
	done
	printf "\n"
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
		mk_piglat "$@"
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

