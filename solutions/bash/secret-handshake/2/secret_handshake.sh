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
00001 = wink
00010 = double blink                                          00100 = close your eyes                                       01000 = jump                                                  10000 = Reverse
FIN
)
#| Θ, Ω                         | 100    |

echo2 "Source : "
echo2 "$Source"

# Ok for values > 100, 1000, etc.. ! 
#  ( Cf after rev          for Values to come first, 
#             sed : puts zeroes back on the right !)
# 
line_datas=( $(echo "$Source" | grep "^[0-9]" | \
                 tr -d '[:punct:]' | \
                 tr -d '=' | \
		 tr -s '.' ' ') )

echo2 "Line_datas : "
echo2 "${line_datas[@]}"

j=-1
declare -a Values=( ) Value_Action=( ) Value_Actions=( )

# Indexed array of <strings of> Actions 
#  ( we also keep binaries as is in Values )
#
# nb : 1 single Associative table should work too
#        though already done for scrabble index 
#        previously, so, next time ?
#
for i in "${line_datas[@]}"
do
	echo2 "i :" "$i"
	if [[ "$i" =~  ^[0-9]+$ ]]
	then
     		echo2 "$i" " Is a Binary Number"
     		Values+=( "$i" )
     		((j+=1))
		Value_Action=( )
	else
		Value_Action+=( "$i" )
	fi
	# A bit redundant while j unchanged
	#   but not in great number's theory : 3
	#   
	Value_Actions[j]="${Value_Action[@]}"
done

# Checking stored datas..
#
echo2 "Values : " "${Values[@]}"

for i in "${!Value_Actions[@]}"
do
	echo2 "Value :" "$i" \
	    " Action :" "${Value_Actions[$i]}"
done

# Some String Globals "used after"..
#  (read only, some are from old resistor 1 script)
#
#                             Fits on 1 line  v
declare -r  PARAMS="$*"                       \
	                                      \
	    REGEX_Syntax='^[0-9]{1}[0-9]{0,1}$'

# B..ts (The good syntax indeed :)
#	    REGEX_Syntax='^[1-9]{1}[0-9]{0,1}$'
# V2-n..
#    REGEX_Syntax1='([1-9]{1}[0-9]{0,1})+'
#    REGEX_SyntaxN="^$REGEX_Syntax1{1}( $REGEX_Syntax1)?$"

echo2 "PARAMS :       " "$PARAMS"
echo2 "REGEX_Syntax : " "$REGEX_Syntax"

# Functions

test_params () {

     # Cf echoes messages
     #
        [ a"$*" == "a" ] \
     && echo2 "Void string is no action.." \
     && echo "Usage: " "$0" " <number between 1-31>" \
     && echo2 "exit 1" && exit 1

     # As required in test #7 (silenced success ?)
        [[ "$#" -eq "0" ]] \
     && echo2 "No parameter is not allowed" \
     && echo2 "Usage: " "$0" " <number between 1-31>" \
     && echo2 "exit 2" && exit 2

     #&& ([[ "$PARAMS" -eq "0" ]] \
     # || [[ "$PARAMS" -gt "31" ]]) \
     #
	[[ ! "$PARAMS" =~ $REGEX_Syntax ]] \
     && [[ "$PARAMS" -eq "0" ]] \
     && echo2 "Not correct range" \
     && echo2 "Usage: " "$0" " <number between 1-31>" \
     && echo "" \
     && echo2 "exit 0" && exit 0
     #&& echo2 "exit 3" && exit 3

	[[ ! "$PARAMS" =~ $REGEX_Syntax ]] \
     && [[ "$PARAMS" -gt "31" ]] \
     && echo2 "Not correct range" \
     && echo "Usage: " "$0" " <number between 1-31>" \
     && echo2 "exit 3" && exit 3
     
	echo2 "valid number!"	
}

# Not to use declare -n
#   ( to get by parameter )
#
#declare -a Code_Bin=( )

Binary_Of () {
	

	#  Var by Name !
	#  ( for modifying Code_Bin of main )
	#
	declare -n Code_bin
	Code_bin="$1"

	# Local array 
	local Code_nb
		
	# Convert to binary
	Code_nb="$(echo "obase=2;" "$PARAMS" | bc )"
	echo2 "Code_nb :" "$Code_nb"

	# Keeps heading zeroes if any
	#  ( saying printf it's a integer)
	#
	Code_nb=$(printf "%05i" "$Code_nb")
	echo2 "Code_nb padded with zeroes :" "$Code_nb"

	# Splitting binary
	#   
	Code_bin=( $(echo "$Code_nb" | sed 's/./& /g') )
	# Ko whatever..
	#Code_bin=( $(echo "${Code_nb//./& /}") )
	echo2 "Code_bin :" "${Code_Bin[@]}"
}

Reverse () {

	# Not to become usual though
	#
	declare -n Array_to_reverse
	Array_to_reverse="$1"

	declare -a Array_reversed=( )

	local j="$((${#Array_to_reverse[@]} - 1))" \
	      i=0
	echo2 "j :" "$j"
	echo2 "!Array_to_reverse" "${!Array_to_reverse[@]}"

	for i in "${!Array_to_reverse[@]}"
	do
		Array_reversed[j]="${Array_to_reverse[i]}"
		echo2 "Array_reversed[j] :" "$j" \
		      "${Array_reversed[j]}"
		((j-=1))
	done

	echo2 "Array_reversed[@] :" \
	      "${Array_reversed[@]}"

	#Array_to_reverse=$Array_reversed   # not ok for
					    # last..
	for i in "${!Array_reversed[@]}"
	do
		Array_to_reverse[i]=${Array_reversed[i]}
	done

	echo2 "Array_to_reverse[@] :" \
	      "${Array_to_reverse[@]}"
}

main () {

	test_params "$@"

	declare -a Result=( ) Code_Bin=( )
	declare -i i 

	# Cf function above 
	#    (var by name)
	#
	Binary_Of Code_Bin

	# Reversing it for // Actions
	# nb : do not put between "" 
	#       (makes split ineffective..)
	#
	Code_Bin=( $(echo "${Code_Bin[@]}" | rev) )
	echo2 "Code_Bin [main 1] :" "${Code_Bin[@]}"

	# Dont take last : is reverse flag       v
	#
	Last=$(("${#Code_Bin[@]}" - 2))
	for i in $(seq "0" "$Last")
	do
		[ "${Code_Bin[i]}" == "1" ] \
	     && Result+=( "${Value_Actions[i]}," )
	done
	
	echo2 "Code_Bin [main 2] :" "${Code_Bin[@]}"
	echo2 "Result   [main] :" "${Result[@]}"

	[ "${Code_Bin["$((Last + 1))"]}" == "1" ] \
     && Reverse Result

	echo2 "Result after reverse :" "${Result[@]}"

	# Need to cut last comma..
	Result2="$(echo "${Result[@]}" \
		 | rev | cut -c 2- | rev)"
	echo2 "Final Result :" "$Result2"

	# Need to remove spaces after commas..
	#   ( aesthetism / real writing practices ?!.. )
	#
	#Result2="$(echo "$Result2" \
	#	 | sed 's/, /,/g')"
	Result2="${Result2//, /,}"
	echo2 "Final Result 2:" "$Result2"

	echo "$Result2"



}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
# (actually, all cases where treated above, weren't they?.)
#
#exit 99
