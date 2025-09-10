#!/usr/bin/env bash
# DR - Ascen+17 - 2025
#
# Maths
#
#	 
#                         
# End Maths 
#
# 

Source=$(cat <<FIN
strength, dexterity, constitution, intelligence, wisdom, charisma, hitpoints,
FIN
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

test_params () {

	# for grep :   escapes 
	#            & quotes in grep arg
	# 2 Numbers between {-}[0-10].[0-9] => Ok !
	#
 REGEX_PARAMS=\
'^\(\(modifier \-\?[0-9][0-9]\?\)\|generate\)$'

#'^-\?\(10\|[0-9]\)\(.[0-9]\)\? -\?\(10\|[0-9]\)\(.[0-9]\)\?$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	# 2 Numbers between {-}[0-10].[0-9] => Ok !
	#
	REGEX_PARAM2=\
'^((modifier -?[0-9][0-9]?)|generate)$'

	# nb: debug printf2 != printf !! 
	#     in function $@->$*  => args ok 
	#
	#Input="$(printf2 "$@" | xargs)"

	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	# At least : MORE ! (Master of Reg. Expr!)
	#  [ Deep // tests.. ]
	#
	printf2 "$Input" | grep -q "$REGEX_PARAMS" \
		                2>/dev/null \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ $Input =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! $Input =~ $REGEX_PARAM2 ]]
	then
		printf2 "Imput Wrong Regex"
# Whatever ( said bob.. )
echo "Usage: $0 generate|modifier <constitution>"
		return 4
	else
		#
		# Refining Regex Checks
		#
		# Keep unquoted to parse
		#               values..
	    if [ "${Input::8}" == "modifier" ]
	    then
		printf2 "modifier.."
		( [[ "${Input:8}" -lt 3 ]] \
	       || [[ "${Input:8}" -gt 18 ]] ) \
               && printf2 "wrong constitution value" \
	       && return 5
		printf2 "modifier Ok!"
		return 3	
	    fi

	    printf2 "generate.."
	    return 2
	fi
}

Score_Coord () {
	:
}

Modifier () {
	[[ "$(($1 % 2))" -eq "0" ]] \
     && echo "$(( ($1 - 10) / 2 ))" \
     && return 1
     
	modifier1="$(($1 - 10))"

        [[ "$modifier1" -le 0 ]] \
     && echo "$(((modifier1 / 2) - 1))" \
     && return 2 

	echo "$((modifier1 / 2))"
	return 0
}

Generate () {
    printf2 "Generating.."
    printf2 "Habilities v: " "${Habilities[@]}"
    printf2 "Sorted Src :" "${Sorted_Src::61}"

    for i in ${Sorted_Src::61}
    do
	# nb : do not use [i] => Messing it all !!
	#
	Habilities[$i]="$(($RANDOM % 15 + 3))"
	printf "%s %i\n" "$i" "${Habilities[$i]}"
    done

    printf2 "\n"
    printf2 "%s " "${Habilities[@]}"
    printf2 "\n"
    printf2 "%s " "${!Habilities[@]}"
    last_key="${Sorted_Src:61}"
    Habilities[$last_key]="$(($(Modifier \
	    "${Habilities["constitution"]}") + 10))"
    printf "%s %i\n" "$last_key" \
	               "${Habilities[$last_key]}"
}


main () {

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    1)
		:
		    ;;
	    2)
		printf2 "Generate"
		declare -A Habilities
		Sorted_Src=$(echo "$Source" | sed 's/,//g')
		for i in $Sorted_Src
		do
			Habilities+=( [$i]=0 )
		done
		printf2 "Habilities v: " "${Habilities[@]}"
		printf2 "Habilities k: " "${!Habilities[@]}"
		Generate
		    ;;
	    3)
		printf2 "Modifier" "${Input:8}"
		Modifier "${Input:8}"
		printf2 "Retour Modifier: " "$?"
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
