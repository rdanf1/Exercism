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
Letter                       | Value |
| ---------------------------- | ----- |                      | A, E, I, O, U, L, N, R, S, T | 1     |
| D, G                         | 2     |
| B, C, M, P                   | 3     |
| F, H, V, W, Y                | 4     |
| K                            | 5     |
| J, X                         | 8     |                      | Q, Z                         | 10    |
FIN
)
#| Θ, Ω                         | 100    |

echo2 "Source : "
echo2 "$Source"

# Ok for values > 100, 1000, etc.. ! 
#  ( Cf after rev          for Values to come first, 
#             sed : puts zeroes back on the right !)
# 
line_datas=( $(echo "$Source" | grep "[0-9]" | \
                 tr -d '[:punct:]' | \
                 tr -d '|' | \
		 tr -s '.' ' ' | \
		 rev | sed -E 's/(0+)([1-9])/\2\1/g') )

echo2 "Line_datas : "
echo2 "${line_datas[@]}"

j=-1
declare -a Values=( ) Value_Letters=( )

# Indexed array of string of letters
#    ( index = value of letters at this index..
#      why : there are less values than letters.)
#
for i in "${line_datas[@]}"
do
	if [[ "$i" =~  ^[1-9]{1}[0-9]?$ ]]
	then
     		echo2 "$i" " Is a Number"
     		Values+=( "$i" )
     		((j=i))
	else
        	Value_Letters[j]+="$i"
	fi
done

# Checking stored datas..
#
echo2 "Values : " "${Values[@]}"

for i in "${Values[@]}"
do
	echo2 "Value " "$i" \
	 " Letters : " "${Value_Letters[$i]}"
done

# Some String Globals "used after"..
#  (read only, some are from old resistor 1 script)
#
#                             Fits on 1 line  v
declare -r  PARAMS="$*"                       \
	                                      \
	    REGEX_Syntax='^[A-Z]+$'
# V2-n..
#	    REGEX_Syntax2='^[a-z]+( [a-z]+)+$' \

echo2 "PARAMS :       " "$PARAMS"
echo2 "REGEX_Syntax : " "$REGEX_Syntax"

# Functions

test_params () {

     # Buggy test for this case #7 : 
     #            "bash color no such file or directory"
     #   [ a"$1" == "afoo" ] && echo "invalid color" \
     #&& exit 5 

     # More cases than required..
     #
     #
        [ a"$*" == "a" ] \
     && echo2 "Void string is 0" \
     && echo "0" \
     && echo2 "exit 0" && exit 0

        [[ "$#" -eq "0" ]] \
     && echo2 "No parameter is 0" \
     && echo "0" \
     && echo2 "exit 0" && exit 0

     PARAMS_UPPER="$(echo "$PARAMS" \
	           | tr '[:lower:]' '[:upper:]')"

     echo2 "PARAMS_LOWER : " "$PARAMS_UPPER"

	[[ ! "$PARAMS_UPPER" =~ $REGEX_Syntax ]] \
     && echo "Usage: " "$0" " <string to evaluate>" \
     && echo2 "exit 1" && exit 1

	echo2 "valid string!"	
}

Value_Of () {

	# We assume 1 unique value for 1 letter
	# nb : no echo2 here, we need proper output
	#
	for i in "${Values[@]}"
	do
		echo "${Value_Letters[$i]}" \
	      | grep -q "$1" \
	     && echo "$i" && return 0
	done
}


main () {

	test_params "$@"

	Word="$PARAMS_UPPER"

	# Avoid default string behaviour..
	declare -i Sum=0

	while [ a"$Word" != "a" ]
	do
		Letter=$(echo "$Word" | cut -c 1 )
		Word=$(echo "$Word" | cut -c 2- )
		Sum+=$(Value_Of "$Letter")
	done

	echo "$Sum"

}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
# (actually, all cases where treated above, weren't they?.)
#
#exit 99
