#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#

# Globals

#declare -r -lu Max1=18446744073709551615
#declare -r -l Max2=9223372036854775807

# Functions

usage () {
	echo "Usage: $0 <year>"
}

test_params () {

        [ "$#" != "1" ] \
     && usage \
     &&	exit 1

        [ -z "$1" ] \
     && usage\
     &&	exit 2

	echo $1 | grep "^[0-9]*\.[0-9]*$" > /dev/null
	val=$?
	[[ $val -eq 0 ]] \
     && usage \
     &&	exit 3

	# long unsigned limit..(max1) 
	# printf "%lu" $((2 ** 64 - 1))
	# OR
	# long signed limit.. (max2)
	# printf "%lu" $((2 ** 63 - 1))
	#
        if [ -n "$1" ] \
	&& ([[ $1 -gt $Max2 ]] \
	|| [[ $1 -lt 1 ]]) 
        then
		#echo "Invalid input (out of bondaries)"
  		usage
		exit 4
	fi
}


main () {

 test_params "$@"

 [[ $(($1 % 4))   -eq 0 ]] && \
 [[ $(($1 % 100)) -ne 0 ]] && echo true && exit 0
 
 [[ $(($1 % 4))   -eq 0 ]] && \
 [[ $(($1 % 100)) -eq 0 ]] && \
 [[ $(($1 % 400)) -eq 0 ]] && echo true && exit 0

 echo false
 exit 0
    
}
# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where processed above, weren't they?.) 
#
exit 99

