#!/usr/bin/env bash
# DR - Ascen+17 - 2025
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

Source=$(cat <<FIN
Ten green bottles hanging on the wall,
Ten green bottles hanging on the wall,
And if one green bottle should accidentally fall,
There'll be nine green bottles hanging on the wall.
FIN
)

One_To_Ten=$(cat <<FIN
One
Two
Three
Four
Five
Six
Seven
Eight
Nine
Ten
FIN
)

printf2 "$Source"

# nb : After "one" there is "no"
declare -r -a One_2_Ten=( "no" $(echo "$One_To_Ten" \
			       | xargs -0) )

for i in "${!One_2_Ten[@]}"
do
	printf2 "$i"
	printf2 "${One_2_Ten[$i]}"
done


# Functions

test_params () {

	# for grep :   escapes 
	#            & quotes  in grep arg
	# 2 Numbers between 1-10 => Ok !
	#
 REGEX_PARAMS='^\(10\|[1-9]\)\( \(10\|[1-9]\)\)\?$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	# Ok : 10 or 1-9 x 2 (2d value optionnal)
	#
	REGEX_PARAM2='^(10|[1-9])( (10|[1-9]))?$'

	# No Need to develop args : "$*" 
	#
	# nb: debug printf2 != printf !! 
	#     in function $@->$*  => args ok 
	#
	#Input="$(printf2 "$@" | xargs)"

	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	# At least : MORE ! (Master of Reg. Expr!)
	#  [ Deep // tests.. ]
	#
	printf2 "$Input" | grep "$REGEX_PARAMS" \
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
echo "2 arguments expected"
		return 3
	else
		# Some tests
printf2 "@A->${Input@A}"; printf2 "@k->${Input@k}"
printf2 ":0->${Input:0}"; printf2 ":1->${Input:1}"
printf2 ":2->${Input:2}"; printf2 ":3->${Input:3}"
		# Nb of chars, indexes
printf2 ":#->${#Input}" ; # printf2 ":!->${!Input}"

		#
		# Refining Regex Checks
		#                ( 
		#declare -a j=( )
		# Keep unquoted to sparse
		#               values..
		for i in ${Input}
		do
			printf2 "i->$i"
			j+=( "$i" )
		done
		printf2 "@j : " "${j[@]}"
		[[ "${#j[@]}" -eq 1 ]] \
	     && printf2 "Imput Ok 1 param" \
	     && return 1
	     
		[[ "${j[1]}" -gt "${j[0]}" ]] && \
echo "cannot generate more verses than bottles" \
	     && printf2 "Imput Wrong 2>1" \
	     && return 3
	
	        printf2 "Imput Ok 2 params"
		return 2
	fi
}

Verse () {
	# nb: [0]="no" (cf above)
	#
	Number=${One_2_Ten[$1]}
	Number_before=${One_2_Ten[$(($1 - 1))]@L}
	printf2 "Nb_1 : " "$Number"
	printf2 "Nb_2 : " "$Number_before"
	
	Source_Verse=$( echo $Source | \
		sed "s/Ten/$Number/g" | \
		sed "s/nine/$Number_before/" | \
sed "s/One green bottles/One green bottle/g" | \
sed "s/one green bottles/one green bottle/g" | \
	        sed 's/, /,\n/g' )
 	
	echo "$Source_Verse"
}

Recite () {
    case "$1" in
	2)
		Verse_No="$2"
		for i in $(seq 1 "$3")
		do
			Recite 1 "$Verse_No"
			((Verse_No--))
		[[ "$3" -gt "1" ]] && \
			printf "\n"
		done
		;;
	1)
		[[ "$2" -gt "0" ]] && \
		Verse "$2"
		;;
    esac

}

main () {

    # Recollect Input
    declare -a j=( )

    # Test arguments
    test_params "$@"

    Return="$?"

    printf2 "Return : " "$Return"
    printf2 "j0 : " "${j[0]}"
    printf2 "j1 : " "${j[1]}"

    # Process
    case "$Return" in
	    1) Recite 1 "${j[0]}"
		    ;;
	    2) Recite 2 "${j[0]}" "${j[1]}"
		    ;;
	    *) printf2 "An Invalid Input Occurred"
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

