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
	   [ "$1" != "-n" ] && echo "$*"
	   [ "$1" == "-n" ] && shift && echo -n "$*"
	fi
	# Always true
	return 0	
}

Source=$(cat <<FIN
- black: 0                                       - brown: 1                                       - red: 2                                         - orange: 3                                      - yellow: 4                                      - green: 5                                       - blue: 6                                        - violet: 7                                      - grey: 8                                        - white: 9
FIN
)

colors=( $(echo "$Source" | \
                 tr -d '[:digit:]' | \
                 tr -d '[:punct:]' | \
		 tr -s '.' ' ' ) )

# Useless : Source has digits sorted : 0..9
#  => same as regular index in an array
#digits=( $(echo "$Source" | \
#                 tr -d 'a-z' | \
#                 tr -d '[:punct:]' | \
#		 tr -s '.' ' ' ) )	

echo2 $Source
echo2 Colors  : ${colors[@]}
echo2 Digits  : ${digits[@]}


declare -A Codes_array=( )
j=0

for i in "${colors[@]}"
do
	echo2 digits $j : "$j"
	Codes_array+=( [$i]="$j" )
	((j+=1))
	echo2 Codes array keys ${!Codes_array[@]}
	echo2 Codes array vals ${Codes_array[@]}
done

# Some String Globals "used after"..
#  (read only, some are from old resistor 1 script)
#
#                             Fits on 1 line  v
declare -r  PARAMS="$*"                       \
	                                      \
            REGEX_color="($(echo ${colors[@]} \
	    		  | sed 's/ /|/g'))"      
declare -r  REGEX_Codes="^($REGEX_color)( $REGEX_color)+$" \
            REGEX_Colors='^colors$'           \
	    REGEX_Code="^code\ $REGEX_color"  \
            REGEX_Cod2='^code\ [0-9]{1}$'     \
	                                      \
	    REGEX_Syntax='^[a-z]+( [a-z]+)+$' \
	    REGEX_Syntax1='^[a-z]+$'

echo2 PARAMS : $PARAMS
echo2 REGEX_color : $REGEX_color
echo2 REGEX_Codes : $REGEX_Codes
echo2 REGEX_Colors : $REGEX_Colors
echo2 REGEX_Code : $REGEX_Code
echo2 REGEX_Cod2 : $REGEX_Cod2

# Functions

test_params () {

     # More cases than required..
     #
	[[ ! "$PARAMS" =~ $REGEX_Colors ]]  \
     &&	[[ ! "$PARAMS" =~ $REGEX_Code ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Codes ]]   \
     &&	[[ ! "$PARAMS" =~ $REGEX_Cod2 ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax ]]  \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax1 ]] \
     && echo Usage: "$0 [color color] color..\
                        |[code <color/digit>]" \
     && echo2 "exit 1" && exit 1

     # Input Syntax is Ok, but at least 1 wrong color    
     #
       	[[ "$PARAMS" =~ $REGEX_Syntax ]]     \
     &&	[[ ! "$PARAMS" =~ $REGEX_Codes ]]    \
     &&	[[ ! "$PARAMS" =~ $REGEX_Syntax1 ]] \
     && echo2 "Valid Colors : ${colors[@]}." \
     && echo "invalid color"                 \
     && echo2 "exit 2" && exit 2


       	[[ "$PARAMS" =~ $REGEX_Syntax1 ]] \
     && ! { echo "${colors[@]}" | grep "$PARAMS" ; } \
     && echo "invalid color" \
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

	# Is correct too though useless echo :
	#for i in $(echo $Colors)
	# nb : no "" in either choice !!
	#
	for i in $Colors
	do
	    ((j+=1))
	    echo2 {Codes_array["$i"]} : "${Codes_array[$i]}"
	    [[ $j -le 2 ]] && Codes+="${Codes_array[$i]}"
	    echo2 j / Codes : "$j" "$Codes"
	done

	# 10# stands for base 10
	#   ( 0<numbers> are bash interpreted as Octal's )
	#   better to cut heading zero if any ?
	#    => adds a condition statement..
	# nb : Removing $ in (()) shouldnt hurt though
	#       actually it does !
	# nb2: 08 or 09 means error for a number !!
	#
	printf "%i\n" $((10#$Codes)) && exit 0
	#printf "%i\n" "$Codes" && exit 0
    fi
	
    if [[ "$PARAMS" =~ $REGEX_Code ]]
    then
	Color=$(echo $PARAMS | cut -d" " -f 2)
	echo "${Codes_array[$Color]}" && exit 0
    fi
    
    # Last valid case Color is single digit query...
    #  code <digit>
    #
    Code="$(echo "$PARAMS" | cut -d" " -f 2)"
    echo2 "digit : $Code"
    echo "${colors[$Code]}"
    exit 0
}

   

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99

