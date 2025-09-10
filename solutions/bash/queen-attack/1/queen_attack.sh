#!/usr/bin/env bash
# DR - Ascen+25 - 2025            
# 					with
#          Keeping notations         	diff.
#
# 7	70│71│72│73│74│75│76│77      wQ   rows,cols
# 6	60│61│62│63│64│65│66│67     -bQ
# 5	50│51│52│53│54│55│56│57      ──
# 4	40│41│42│43│44│45│46│47      00 = same : err
# 3	30│31│32│33│34│35│36│37      x0│= true : att
# 2	20│21│22│23│24│25│26│27      0y│= true : att
# 1	10│11│12│13│14│15│16│17
# 0  	00│01│02│03│04│05│06│07      
#
#  0 1 2 3 4 5 6 7      
#
#  Diagonals :
#            wQ = bQ ± 11n      wQ = bQ ± 9n
#  	     wQ + bQ = 11n	wQ + bQ = 9n
#  	     wQ - bQ = 11n	wQ - bQ = 9n
#
#   so if ie wQ > bQ : 
#                    (wQ - bQ) mod 11 = 0 => true
#                or  (wQ - bQ) mod 9  = 0 => true 

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
	#
	# -w x₁,y₁ -b x₂,y₂   / x₁,y₁,x₂,y₂ ∈ [0-7]
	#
 REGEX_PARAMS=\
'^-w [0-7],[0-7] -b [0-7],[0-7]$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#                  
	REGEX_PARAM2=\
'^-w [0-7],[0-7] -b [0-7],[0-7]$'

	# Warn
	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	#  [ Deep regex // tests.. ]
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
            # Refining Regex Wrong cases 
  	    #
	REGEX_PARAM_NEG_ROW=\
'^-w -?[0-7],[0-7] -b -?[0-7],[0-7]$'
	[[ $Input =~ $REGEX_PARAM_NEG_ROW ]] \
     && echo "row not positive" && exit 1
	REGEX_PARAM_NEG_COL=\
'^-w [0-7],-?[0-7] -b [0-7],-?[0-7]$'
	[[ $Input =~ $REGEX_PARAM_NEG_COL ]] \
     && echo "column not positive" && exit 2
	REGEX_PARAM_OUT_ROW=\
'-(w|b) [8-9],'
	[[ $Input =~ $REGEX_PARAM_OUT_ROW ]] \
     && echo "row not on board" && exit 3
	REGEX_PARAM_OUT_COL=\
',[8-9]'
	[[ $Input =~ $REGEX_PARAM_OUT_COL ]] \
     && echo "column not on board" && exit 4
	    
	    # Whatever ( said bob.. A LOT !!..)
	    echo "Check the @tests bro.."
	    return 5
	else
	    #
            # Refining Regex Checks
  	    #
	    Input="$(echo "$Input" \
		   | tr -cd '[:digit:]')"
	    Coord1="${Input::2}"
	    Coord2="${Input:2}"
	    printf2 "Coord1 :" "$Coord1"
	    printf2 "Coord2 :" "$Coord2"

	    [[ "$Coord1" -eq "$Coord2" ]] \
	 && echo "same position" && exit 5

	    printf2 "Arguments Ok !"
	    return 0
	fi
}

is_Attack () {

    # Return duplicate values if any
    #
     if [[ "$Coord1" -gt "$Coord2" ]]
	then
		Diff="$((Coord1 - Coord2))"
	else
		Diff="$((Coord2 - Coord1))"
     fi

     
   printf2 "Coord1::1" "${Coord1::1}"
   printf2 "Coord2::1" "${Coord2::1}"
     [[ "${Coord1::1}" -eq "${Coord2::1}" ]] \
  && printf2 "Diff::1" "${Diff::1}" \
  && echo "true" && exit 0

   printf2 "Coord1:1:1" "${Coord1:1:1}"
   printf2 "Coord2:1:1" "${Coord2:1:1}"
     [[ "${Coord1:1:1}" -eq "${Coord2:1:1}" ]] \
  && printf2 "Coord:1:1" "${Coord:1:1}" \
  && echo "true" && exit 0

     [[ "$((Diff % 11))" -eq 0 ]] \
  && printf2 "Diff % 11" \
  && echo "true" && exit 0

     [[ "$((Diff % 9))" -eq 0 ]] \
  && printf2 "Diff % 9" \
  && echo "true" && exit 0
    
     echo "false" && exit 0
}

main () {

    declare -i Coord1=0 Coord2=0 

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		is_Attack
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

