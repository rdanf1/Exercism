#!/usr/bin/env bash
# DR - Ascen+11 - 2025
#

# Debug mode [ mainly  for echoes from 
#             'echo2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
#    Usage: echo2 "<echo param>" "<values..>"
#
echo2 () {
	# TODO : Manage *any* echo parameters
	if [[ "$DEBUG" -gt "0" ]]
	then
	   [ a"$1" != "a-n" ] && echo "$*"
	   [ a"$1" == "a-n" ] && shift && echo -n "$*"
	fi
	# Always true
	return 0
}

Source=$(cat <<FIN
- black: 0                                       - brown: 1                                       - red: 2                                         - orange: 3                                      - yellow: 4                                      - green: 5                                       - blue: 6                                        - violet: 7                                      - grey: 8                                        - white: 9
FIN
)

echo2 "Source : " "$Source"

colors=( $(echo "$Source" | \
                 tr -d '[:digit:]' | \
                 tr -d '[:punct:]' | \
		 tr -s '.' ' ' | xargs) )

echo2 "Colors  : " "${colors[@]}"

# Useless : Source has digits sorted : 0..9
#  => same as regular index in an array
#digits=( $(echo "$Source" | \
#                 tr -d 'a-z' | \
#                 tr -d '[:punct:]' | \
#		 tr -s '.' ' ' ) )	
#echo2 "Digits  : " "${digits[@]}"



declare -A Codes_array=( )
j=0

for i in "${colors[@]}"
do
	echo2 "digits j : " "$j"
	Codes_array+=( [$i]="$j" )
	((j+=1))
	echo2 "Codes array keys : " "${!Codes_array[@]}"
	echo2 "Codes array vals : " "${Codes_array[@]}"
done

# Some String Globals "used after"..
#  (read only, some are from old resistor 1 script)
#
#                             Fits on 1 line  v
declare -r  PARAMS="$*"                       \
	                                      \
            REGEX_color="($(echo "${colors[@]}" \
	   		  | sed 's/ /|/g'))"
declare -r  REGEX_Codes="^($REGEX_color)( $REGEX_color)+$" \
            REGEX_Colors='^colors$'           \
	    REGEX_Code="^code\ $REGEX_color"  \
            REGEX_Cod2='^code\ [0-9]{1}$'     \
	                                      \
	    REGEX_Syntax='^[a-z]+( [a-z]+)+$' \
	    REGEX_Syntax1='^[a-z]+$'

echo2 "PARAMS : " "$PARAMS"
echo2 "REGEX_color : " "$REGEX_color"
echo2 "REGEX_Codes : " "$REGEX_Codes"
echo2 "REGEX_Colors : " "$REGEX_Colors"
echo2 "REGEX_Code : " "$REGEX_Code"
echo2 "REGEX_Cod2 : " "$REGEX_Cod2"
echo2 "REGEX_Cod2 : " "$REGEX_Syntax"
echo2 "REGEX_Cod2 : " "$REGEX_Syntax1"

# Functions

test_params () {

     # Buggy test for this case #7 : 
     #            "bash color no such file or directory"
     #   [ a"$1" == "afoo" ] && echo "invalid color" \
     #&& exit 5 

     # More cases than required..
     #
	[[ ! "$PARAMS" =~ $REGEX_Colors ]]  \
     &&	[[ ! "$PARAMS" =~ $REGEX_Code ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Codes ]]   \
     &&	[[ ! "$PARAMS" =~ $REGEX_Cod2 ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax ]]  \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax1 ]] \
     && echo "Usage: " "$0" " [color color] color..\
                     or [code <color/digit>]" \
     && echo2 "exit 1" && exit 1

     # Input Syntax is Ok, but at least 1 wrong color    
     #
       	[[ "$PARAMS" =~ $REGEX_Syntax ]]     \
     &&	[[ ! "$PARAMS" =~ $REGEX_Colors ]]   \
     &&	[[ ! "$PARAMS" =~ $REGEX_Codes ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Code ]]     \
     &&	[[ ! "$PARAMS" =~ $REGEX_Cod2 ]]     \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax1 ]]  \
     && echo2 "Valid Colors : " "${colors[@]}" "." \
     && echo "invalid color" \
     && echo2 "exit 2" && exit 2


     # 1 single parameter and not a color name
     #
       	[[ "$PARAMS" =~ $REGEX_Syntax1 ]]   \
     &&	[[ ! "$PARAMS" =~ $REGEX_Colors ]]  \
     &&	[[ ! "$PARAMS" =~ $REGEX_Codes ]]   \
     &&	[[ ! "$PARAMS" =~ $REGEX_Code ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Cod2 ]]    \
     && ! { echo "${colors[@]}" | grep -q "$PARAMS" ;} \
     && echo "invalid color" \
     && echo2 "1 wrong Color : " "$1" \
     && echo2 "exit 3" && exit 3

	echo2 "valid color!"	
}


main () {

    test_params "$@"

    if [[ "$PARAMS" =~ $REGEX_Codes ]]
    then
	Colors="$PARAMS"
	Codes=""
	j=0
	nb_zeros=0
	# Is correct too though useless echo :
	#for i in $(echo $Colors)
	# nb : no "" in either choice !!
	#
	for i in $Colors
	do
	    ((j+=1))
	    echo2 "{Codes_array[$i]} : " "${Codes_array[$i]}"
	    [[ $j -le 2 ]] && Codes+="${Codes_array[$i]}"
	    [[ $j -eq 3 ]] && nb_zeros="${Codes_array[$i]}"
	    echo2 "j / Codes : " "$j" " " "$Codes"
	done
	
	[ "$Codes" == "00" ] \
		&& echo "0 ohms" \
		&& exit 0

	# Adds a zero if 2d color is black=0
	if [[ "${Codes:1:1}" -eq 0 ]]
	then
		zeros="0" ; Codes="${Codes::1}"
	fi

	echo2 "Codes : $Codes"

	case "$nb_zeros" in

		0)
		   zeros+="" ; ohms="ohms"
			;;
	        1)
		   zeros+="0" ; ohms="ohms"
			;;
		2)
		   zeros+="00" ; ohms="ohms"
			;;
	        3)
		   zeros+="000" ; ohms="kiloohms"
			;;
		4)
		   zeros+="0000" ; ohms="kiloohms"
			;;
		5)
		   zeros+="00000" ; ohms="kiloohms"
			;;
	        6)
		   zeros+="000000" ; ohms="megaohms"
			;;
		7)
		   zeros+="0000000" ; ohms="megaohms"
			;;
	        8)
		   zeros+="00000000" ; ohms="megaohms"
			;;
		9)
		   zeros+="000000000" ; ohms="gigaohms"
			;;
	esac
	
	echo2 "all zeros : $zeros"
	nb_zeroes=${#zeros}
	echo2 "nb zeros : $nb_zeroes"

	if [[ "nb_zeroes" -ge 9 ]]
	then
		zeros=${zeros//000000000/}
		ohms="gigaohms"
	else
	  if [[ "nb_zeroes" -ge 6 ]]
	  then
		zeros=${zeros//000000/}
		ohms="megaohms"
	  else
	    if [[ "nb_zeroes" -ge 3 ]]
	    then
		zeros=${zeros//000/}
		ohms="kiloohms"
	    fi
	  fi
	fi

	echo2 "Codes : $Codes"

	# 10# stands for base 10
	#   ( 0<numbers> are bash interpreted as Octal's )
	#   better to cut heading zero if any ?
	#    => adds a condition statement..
	# nb : Removing $ in (()) shouldnt hurt though
	#       actually it does !
	# nb2: 08 or 09 means bash error for a number !!
	#
	#printf "%i\n" "$Codes" && exit 0
	printf "%i%s %s\n" "$((10#$Codes + 0))" \
		           "$zeros" "$ohms" \
			   && exit 0
    fi
	
    if [[ "$PARAMS" =~ $REGEX_Colors ]]
    then
	echo "Valid Colors : " "${colors[@]}" && exit 0
    fi

    if [[ "$PARAMS" =~ $REGEX_Cod2 ]]
    then
	Code=$(echo "$PARAMS" | cut -d" " -f 2)
    	echo2 "digit : " "$Code"
	echo "${colors[$Code]}" && exit 0
    fi
    
    if [[ "$PARAMS" =~ $REGEX_Code ]]
    then
	Color="$(echo "$PARAMS" | cut -d" " -f 2)"
	echo "${Codes_array[$Color]}" && exit 0
    fi
    
    if [[ "$PARAMS" =~ $REGEX_Syntax1 ]]
    then
	echo "valid color" && exit 0
    fi

}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
# (actually, all cases where treated above, weren't they?.)
#
#exit 99
