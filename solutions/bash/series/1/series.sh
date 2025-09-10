#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#
# Just Maths : 
#     Consecutive sub-arrays of n elements
#     of an array of N elements is :
#
#     [1..............N]       
#     [1..n]                 = S[1] 
#      [2..n]                = S[2] 
#       [3..n]               = S[3]
#             ...            ...
#               [N-n..N]     = S[N-n]
#
#     So there are N-n consecutives sub-series of n
#     elements in the sequence of N elements
#     
#     Seems Pretty Simple to transform this Pb into
#     recurrence solution
#
#     Constrains:
#     1. No Bash Array (use only strings)
#     2. Recursive
#
#     Trivial cases : 
#                    N=n=1 :  S(1)=[1]
#             Or
#                      n=N :  S(n)=[1..n]
#
#             with  [1..n] =
#                { digits from range 1 to N of sequence }
#     
#     Recursive Iteration :                 Trivial!
#                                              vvv
#         S[N](n) = { [1..n], S[N-1](n), .. , S[N-n](n) } 
#
#     With S[N-i] = { Sub-sequence i of Sequence N //
#                     S(i) = Sequence N - (i first digits) }
#
#     DONE FOR Maths..
#
  
DEBUG=0

# Functions

# Debugging echoes 
#    Usage: echo2 "<echo param>" "<values..>"
# (Beware of really needed echoes if using substitutions
#   ie line 111 or so...)
#
echo2 () {
	# TODO : Manage *any* echo parameters
	if [[ "$DEBUG" -gt "0" ]] 
	then
	   [ "$1" != "-n" ] && echo "$*"
	   [ "$1" == "-n" ] && shift && echo -n "$*"
	fi
	return 0	
}

test_params () {

     # Seems a bit long..
     #
        [ "$#" != "2" ] \
     && echo2 "At least 2 parameter needed" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 "exit 1" \
     && exit 1
     echo2 "1 passed"

       [ "$1" == "" ] \
    && echo  "series cannot be empty" \
    && exit 2

       [ "$2" == "" ] \
    && echo  "span must not be empty chain" \
    && exit 2

       [[ $2 -lt 0 ]] \
    && echo "slice length cannot be negative" \
    && exit 3

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo "input must only contain digits" \
     &&	echo2 "Usage: $0 <input digits> <series size>" \
     && echo2 "exit 3" && exit 3
     echo2 "3 passed"

     #  Here we know there is 2 parameters 
     #  both are numbers and $2 < 99

       [[ $2 -eq 0 ]] \
    && echo "slice length cannot be zero" \
    && echo2 "exit 4" && exit 4
    echo2 "4 passed"

    # Sub array length
    Span_Length="$2"
    n=$Span_Length
    
    # A String
    #                     
    Input="$1"

    # Size of sequence 
    Input_Length="${#Input}"

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo "input must only contain digits" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 "exit 3" && exit 3
     echo2 "3 passed"

       [[ "${#Input}" -lt "$Span_Length" ]] \
    && echo  "slice length cannot be greater than series length" \
    && echo2 "Sorry : Length of span must be less \
                     than length of Input values" \
    && echo2 "exit 5" && exit 5
    echo2 "5 passed"

    echo2 "Input :" "$Input" "Length :" "$Input_Length"
    echo2
    echo2 "Span Length :"  "$Span_Length"
    echo2	

}

Display_Serie () {

	# Tests in params & main
	#  at least 1 iteration though
	
	# By name for testing.. 
	#  ( Not useful here recursive func gives
	#    the results and ends recursions
	#    when all results were displayed )
	#
	# declare -n Sequence
	Sequence="$1"

	local Result2=""

	Result+=$( printf "%s " $(echo "$Sequence" \
		| cut -c 1-$2) )

	Sequence="$(echo "$Sequence" | cut -c 2-)"

	# Trivial case (cant iterate next)
	#   ( nb : using array notation with a string
	#          for getting string's size [0].. )
	#
	[[ "${#Sequence}" -lt "$2" ]] \
     && Result+="$(printf "\n")" \
     && Result2="$(echo $Result)" \
     && echo "$Result2" \
     && return 0

	# Recursing with named var (see above)
	#  Should be ok to preserve memory ? [**]
	#   ( why not doing the same for n = $2 ?)
	#
	Display_Serie $Sequence $2

}

# Useless but
#   Kept from Previous series exercism
#
Case_0 () {
	:
}

main () {

    test_params "$@"

    echo2 "Input  : $Input"
    echo2 "Length : $Input_Length"
    echo2 "Main n : $n"

    Display_Serie $Input $n 

    # This isnt the result ! (lol)
    #  ( => output incorrect ? ):
    #echo

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#[[ $DEBUG -gt 0 ]] && exit 99

