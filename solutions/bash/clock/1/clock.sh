#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#

#
# epochs in sec since 01/01/1970 01:00:00
#
#  offset choosen somewhere in between (or 3/4) :
#                   25/12/1997 00:00:00
#
declare -r -i TIME_OFFSET="$((60*60*24*365*28-60*60))"


# Debug mode [ mainly  for echoes from 
#             'printf2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0


# to check
#    and for further mesurements
#
#date --date="@$((60*60*24*365*28-60*60))"


Clock1 () {

	printf2 "$*"
	printf2 "$1" "$2" "$3" "$4"
	
	declare -i Hour=0 \
		   Min=0  \
		   Min_PM=0 \

	Hour="$(( ${1}*60*60 ))"
	Min="$(( ${2}*60 ))"
	Min_PM="$(( ${3}${4}*60 ))"

	Clock=$(( $TIME_OFFSET + $Hour + $Min \
			       + $Min_PM ))

	date "+%H:%M" --date="@$((Clock))"
				  
}

# Functions

# Debugging printf
#
#    Usage: printf2 "<values..>"
#
printf2 () {

	if [[ "$DEBUG" -gt "0" ]] 
	then
		printf '"%s"\n' "$*"
	fi
	# Always true
	return 0	
}

test_params () {

	# Escaping *all* but *2 chars* 
	#                    to evaluate !
	#           => wrong again..
	#              though grep is ok
	#              with 2d form..
	#
	REG_Sign='(\+|\-)'
#	REG_Sign='\(+\|-\)'

	REG_Numb='[0-9][0-9]*'
	
# Couldn't achieve both with a single
#  regex.. [ issues with '$' and '?' ]
#
REGEX_Input2="^-?$REG_Numb -?$REG_Numb"
REGEX_Input4="^-?$REG_Numb -?$REG_Numb( $REG_Sign $Reg_Numb)"

	printf2 "$*"
	printf2 "$@"
	
	# Not good practice but quick
	#   ( better use for [..]) 
	#
	Input=( $(printf "%s\n" "$*") )

	# For some peculiars tests
	printf2 "Input :" "${Input[@]}"
	j=0
	for i in "${Input[@]}"
	do
		((j+=1))
		# Here assign args [..]
		printf2 "$j" "$i"
	done

	# Could improve wrong regex though
	echo "${Input[@]}" | grep -q '/' && \
     	    printf2 "Invalid arguments" \
      	&&  printf2 "Usage : $0 <hour> <min> [+- <min>]" \
 	&&  return 3


	[[ "$j" -ne "4" ]] \
     && [[ "$j" -ne "2" ]] \
     && printf2 "Invalid arguments" \
     && printf2 "Usage : $0 <hour> <min> [+- <min>]" \
     && return 3

	# Taking well formed Input #2 (check 1st)
	#     	
	if [[ "${Input[@]}" =~ $REGEX_Input4 ]]
	then
		printf2 "4 arguments ok!"
		return 4
	fi
	
	# Taking well formed Input #1 (check 2d)
	#     	
	if [[ "${Input[@]}" =~ $REGEX_Input2 ]]
	then
		printf2 "2 arguments ok!"
		return 2
	fi

	printf2 "Not Reg, invalid input..."
	return 1
}

main () {

	declare -a Input=( )

	test_params "$@"
	
	Return="$?"
	printf2 "Return: $Return"

	case "$Return" in
	 2)
	    printf2 "${Input[0]}" "${Input[1]}" "+" "0"
	    Clock1 "${Input[0]}" "${Input[1]}" "+" "0"
	    ;;
	 4)
	    Clock1 "${Input[0]}" "${Input[1]}" "${Input[2]}" "${Input[3]}"
	    ;;
	 *)
	    echo "invalid arguments"
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

