#!/usr/bin/env bash
# DR - Ascen+10 - 2025
#

# Globals


# Debug mode [ mainly  for echoes from 
#             'echo2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0

declare -A Coding_array Source2

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

# Wasnt a function though in the middle of nowhere..
#  [ kept un-indented sorry..]
Source_to_Codes_Array () {

# Source Codes ! [ Always raw pasted from Readme.md ! ]
#
Source=$(printf "%s" '
- `G` -> `C`                                          - `C` -> `G`                                          - `T` -> `A`                                          - `A` -> `U`' | sed 's/`//g' | tr -d '[:punct:]' \
	      | xargs
)

#
# Process of creating an associative coding table :
# 1. Indexing is [1]=1st key, [2]=1st value, etc..
# 2. Appending key value 1 by 1 in pseudo for i,j ..
#
# NB : All tries (many!) to construct Associative
#      array directly from other variables werent
#      successful => postponed.. 
#               ( source_array function, etc.. )
#      

# As usual for *my* indexed arrays : 
#     padding [0] with "" (Empty string) 
#     for real index values between 1 and #Array
Source3=( "" $(echo $Source) )

echo2 2 : $Source
echo2 3 : ${#Source3[@]}

declare -i i j=0

# Populates RNA Coding Table
# 
# [ Kind of "for i,j .." bash implementation ]
#   => Added to DR Tools at bottom
# nb : values for i,j = using 2 variables for
#      and remember Source was prefilled at [0] with ""
#      I mean it makes more sense for indexing values !
#
incr=2
end="$(( ${#Source3[@]} - $(($incr - 1)) ))"

for i in $(seq 1 $incr $end)
do
	((j=i+1))
	echo2 i ${Source3[$i]} j ${Source3[$j]}
	Coding_array+=( 
		[${Source3[$i]}]="${Source3[$j]}"
	)
done

echo2 Coding Scheme : ${Coding_array[@]}
echo2 Coding Keys :   ${!Coding_array[@]}

echo2 Coding Scheme 0 : ${Coding_array[0]}
echo2 Coding Scheme A : ${Coding_array["A"]}

}

# Functions

test_params () {

     # Empty chain
     #
       [ "$*" == "" ] \
    && exit 0

        [ "$#" != "1" ] \
     && echo "1 parameter needed" \
     &&	echo "Usage: $0 <rna sequence> (GCTA..)" \
     && echo2 "exit 1" \
     && exit 1
     echo2 "1 passed"

     # Empty chain
     #
       [ "$*" == "" ] \
    && exit 0

	# Input chain [unlimited]
	REGEX_RNA='^(G|C|T|A)+$'
        [[ ! "$*" =~ $REGEX_RNA ]] \
     &&	echo2 "Only rna codes are allowed" \
     &&	echo2 "Usage: $0 <rna sequence> (GCTA..)" \
     && echo2 "exit 3" \
     && echo "Invalid nucleotide detected." \
     && exit 3
     echo2 "3 passed"
}


declare -a Input_str=( "" )

Input_Array () {

#
# Converting Input as An array of chars      
#    [n0t debug echo2 here..] 
#
# This *quick* construction can be space/time 
#   consuming with *long* sequences.. (or not?)
# a while and cut with appending in index array
# should be better > just after params_check func
# 
#declare -a Input=( "" )
#Input=( $(echo "$1" | sed -s 's/./& /g') )
#Length="${#Input[@]}"

#echo2 "Input : ${Input[@]} Length : $Input_Length"
#echo2
	# A better way than above ?
	
	local Remain_str=$(printf "%s" "$*")
	local declare i=0

	# Picks chars from Input 
	#  and puts them into an indexed array
	#
	while [ a"$Remain_str" != "a" ]
	do
		# Increment indexed array
		Input_str+=( $(echo $Remain_str | cut -c 1) )
		Remain_str=$(echo $Remain_str | cut -c 2-)
		echo2 Input_str  : "${Input_str[@]}" 
		echo2 Remain_str : "${Remain_str[@]}"

		# If debug, Stops => need <Enter> 
		#       or <whatever enter> is required..
		#
		[[ $DEBUG -gt 0 ]] && echo "<CR> Plz.." \
                           && read q
	done
	echo2 Input_str : "${Input_str[@]}" 
	echo2 Input_str 1 : "${Input_str[1]}" 
}

main () {

    # Checking arguments
    # 	
    test_params "$@"

    # Ready to Compute..
    Input_Array "$@"

    # Thinking part (Associative Array)
    Source_to_Codes_Array
   
    # Lots of debugs outputs..
    echo2 In Main Input_str : "${Input_str[@]}"
    echo2 In Main Input_str 0 : "${Input_str[0]}"
    echo2 In Main Input_str 1 : "${Input_str[1]}"
    echo2 In Main Coding_array keys   : "${!Coding_array[@]}"
    echo2 In Main Coding_array values : "${Coding_array[@]}"

    for i in $(seq 1 "$((${#Input_str[@]} - 1))" ) 
    do
	    echo2 Input_str $i : "${Input_str[$i]}"
	    printf "%s" "${Coding_array[${Input_str[$i]}]}"
	    echo2
    done

    # Guess why ?
    echo

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#[[ $DEBUG -gt 0 ]] && exit 99