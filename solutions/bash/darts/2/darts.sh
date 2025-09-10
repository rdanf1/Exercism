#!/usr/bin/env bash
# DR - Ascen+17 - 2025
#
# Maths
#
#  A ) We need to compute sqrt(x ** 2 + y ** 2)
#  / x, y = (-)dd.d
#
#  1. Digits Approximation of sqrt ...
#
#  B ) Geometric approch
#
#     x ~ y => 45° = θ
#
#     hyp = adj. / cos(θ)
#     hyp = opp. / sin(θ)
#
#  C ) Algebraic approch : 
#
#  	x^2 + y^2 = r^2 => if x^2 + y^2 > r^2 Out !
# 
#
# (C) is better : 
#
#      if 
#       1. x^2 + y^2 >  10^2 = 100 => Out !
#
#       2. x^2 + y^2 <= 10^2 = 100 => In !
#                         
# End Maths 
#
#  D ) Bash Float 
#      scale required is 1 decimal ( cf @test )
#
#      => if float x 10 values <=> 1.6 => 16, etc...
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


# Functions

is_float () {
	echo "$1" | grep -q "\." \
     && return 0

	return 1
}

is_negative () {
	echo "$1" | grep -q "\-" \
     && return 0

	return 1
}
x10_float () {
	if is_float "$1" ;
	then
	    if is_negative "$1" ;
	    then
		echo "$(( "$(echo $1 | cut -d"." -f 1)" * 10 - "$(echo "$1" | cut -d"." -f 2)" ))"
	    else
		echo "$(( "$(echo $1 | cut -d"." -f 1)" * 10 + "$(echo "$1" | cut -d"." -f 2)" ))"
	    fi
	else
		echo "$(( "$1" * 10 ))"
	fi
}

test_params () {

	# for grep :   escapes 
	#            & quotes in grep arg
	# 2 Numbers between {-}[0-10].[0-9] => Ok !
	#
 REGEX_PARAMS=\
'^-\?\(10\|[0-9]\)\(.[0-9]\)\? -\?\(10\|[0-9]\)\(.[0-9]\)\?$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	# 2 Numbers between {-}[0-10].[0-9] => Ok !
	#
	REGEX_PARAM2=\
'^-?(10|[0-9])(.[0-9])? -?(10|[0-9])(.[0-9])?$'

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
		return 4
	else
		#
		# Refining Regex Checks
		#
		# Keep unquoted to sparse
		#               values..
		for i in ${Input}
		do
			printf2 "i->$i"
			j+=( "$i" )
		done
		printf2 "@j : " "${j[@]}"
	     
		is_float "${j[1]}"
		printf2 "Return is_float : " "$?"


		( is_float "${j[0]}" || \
		  is_float "${j[1]}" )  \
	     && printf2 "Imput contains Floats " \
	     && return 3
	
	        printf2 "Imput Ok no Floats"
		return 2
	fi
}

Score_Coord () {

    X2_Y2="$(("$2" ** 2 + "$3" ** 2))"

    [[ "$1" -eq "1" ]] \
 && RADIUS="100"
    
    RADIUS="${RADIUS:="10"}"

    printf2 "Radius : " "$RADIUS"
    printf2 "X2_Y2 : " "$X2_Y2"

    if [[ "$X2_Y2" -gt "$((RADIUS ** 2))" ]]
    then
	echo "0"
    else
	    if [[ "$X2_Y2" -gt "$(((RADIUS / 2) ** 2))" ]]
	then
	    echo "1"
	else 
	    if [[ "$X2_Y2" -gt "$(((RADIUS / 10) ** 2))" ]]
	    then
	        echo "5"
	    else
		echo "10"
	    fi
	fi
    fi
}


main () {

    # Recollect Input
    declare -a j=( )

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    1)
		:
		    ;;
	    2)
		printf2 "Score_Coord 0 : " "${j[0]}" "${j[1]}"
		Score_Coord "0" "${j[0]}" "${j[1]}"
		    ;;
	    3)
		X10=$(x10_float "${j[0]}")
		Y10=$(x10_float "${j[1]}")
		printf2 "X10, Y10" "$X10" "$Y10"
		printf2 "Score_Coord 1 : " "$X10" "$Y10"
		Score_Coord "1" "$X10" "$Y10"
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

