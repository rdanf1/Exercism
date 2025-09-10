#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Analyse

declare -A alph=( ) phal2=( )
declare -a phal=( ) alph2=( )

j=0
# nb : this space ----v is important !!
# factorise {ab}{cd}  |    = ac ad bc bd !
for i in $(echo {z..a} {0..9})
do
	phal+=( "$i" )
	phal2+=( ["$i"]="$j" )
	((j++))

done

j=0
for i in $(echo {a..z} {0..9})
do
	alph+=( ["$i"]="$j" )
	alph2+=( "$i" )
	((j++))
done


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
'^[ -~]*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[ -~]*$'

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
	# From here $Input2 is sentence 
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    Input2="$(echo $Input2 | tr -d '[:punct:]')"
	    Input2="$(echo $Input2 | tr -d ' ')"
	    Input2="$(echo $Input2 | tr '[:upper:]'  '[:lower:]')"
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_cipher () {
	
    type="$1"
    Input2="${Input2:6}"

    if [ "$type" == 'encode' ]
    then
	i=0
	while [[ "${#Input2}" -ne 0 ]]
	do
	    ((i++))
	    printf "%s" "${phal["${alph["${Input2:0:1}"]}"]}"
	    [[ "$i" -eq 5 ]] \
         && i=0 && [[ "${#Input2}" -ne 1 ]] \
         && printf ' '
	        
	    Input2="${Input2:1}"
	done

    else
	i=0
	while [[ "${#Input2}" -ne 0 ]]
	do
	    ((i++))
	    printf "%s" "${alph2["${phal2["${Input2:0:1}"]}"]}"
	    Input2="${Input2:1}"
	done
	    :
    fi
    printf '\n'
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
		mk_cipher "$@"
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

