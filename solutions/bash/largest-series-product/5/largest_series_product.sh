#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#
# Just Maths : 
#     Consecutive sub-arrays of n elements
#     of an array of N elements is :
#
#     [1..............N]
#     (1..n)
#      (1..n)
#       (1..n)
#              (N-n..N)
#
#     So there are N-n consecutives sub-series in N
#     
#     We're talking of consecutive digits to
#     multiply together and maximise the result
#     	
#     Trivial values are :
#        i.e. for span=3 , 999 ( all nines ) is optimal
#      And we know 0nn n0n nn0 (One 0 in span) is minimal
#      	
#     more generally, if not trivial values,
#       if (abc) are first digits we keep
#     then a+b+c is enough to compute further 
#     because if (a+b+c) > (d+e+f) 
#           then a*b*c > d*e*f
#
#     though we keep summing same consecutive numbers
#     after summing (abc) we sum (bcd) : bc was added bfor
#     means its better summing last 1st
#     makes it as a LIFA (Last In First Added - Heap/Stack)
#
#     DONE FOR Maths..
#
#     Seems Pretty Simple to transform this Pb into
#     recurrence solution :
#
#     Max[N, n, i, j] = Max[N-1, n, i, j+1]
#
#     With i the address of Temporary Computed Maximized 
#     serie in N, and i.e. with a span size of 3, 
#     i=0 at beginning so n0*n1*n2 is the initial Optimum
#
#     for obscure computational reasons I added j :
#     j is the range we have completed in N {starts at 0}
#     etc...
#
# NB : This implementation keeps 1st optimum
#      encountered in compute process (as described above),
#      further equals optimum are skipped. [ -gt search ]
#
  
Max=1
Max_Value=0
Sum_Prev=0
Sum=0
Prod=1

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
}

test_params () {

        [ "$#" != "2" ] \
     && echo2 "At least 2 parameter needed" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 exit 1 && exit 1
     echo2 1 passed

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 exit 2 && exit 2
     echo2 2 passed

     #  Here we know there is 2 parameters 
     #  both are numbers and $2 < 99

       [[ $2 -eq 0 ]] \
    && echo2 "2d Argument must be greater than zero" \
    && echo2 exit 4 && exit 4
    echo2 4 passed


    # Sub array length of Input to maximize
    Span_Length="$2"
    n=$Span_Length
    
    # An array of chars
    Input=( $(echo "$1" | sed -s 's/./& /g') )
    Input_Length="${#Input[@]}"

       [[ "${#Input[@]}" -lt "$(($Span_Length))" ]] \
    && echo2 "Sorry : Length of span must be less \
                     than length of Input values" \
    && echo2 exit 5 && exit 5
    echo2 5 passed

    echo2 Input : ${Input[@]} Length : $Input_Length
    echo2
    echo2 Span Length $Span_Length
    echo2	

    # Previous partial sum (d for digit):
    # Avoid re-computing (n-1)/n % of Sum
    #  = d[i]+d[i+1]+..+d[i+n -1]
}


Sum_Curr () {
        # We assume we already checked
	#  if Input[$1 + n] is valid and not 0
	#

	ind1=$(($1 - 1))
	indn=$(($1 + n - 2))

	Val1=${Input[$ind1]}
	Valn=${Input[$indn]}
	
	echo2 Indice $1 Value $Val1
	echo2 Valn : $Valn

	if [[ "$Sum_Prev" != "0" ]]
	then
            echo2 Sum_Prev : $Sum_Prev
	    Sum=$(( $Sum_Prev + $Valn ))
	    
	    # If span > 2    - $Val1 \
	    #                + $Valn didnt work..
	    #
            Sum_Prev=$(( Sum_Prev - $Val1 ))
	    
	    for i in $(seq $((ind1 + 1)) $indn)
	    do
		Sum_Prev=$(( Sum_Prev + ${Input[$i]} ))
	    done
	else
            echo2 1st  arg : $(($1 - 1))
            echo2        n : $n
            echo2 last arg : $(($1 + n - 2))

	    for i in $(seq $(($1 - 1))  $(($1 + n - 2)))
	    do
		Sum=$(( Sum += ${Input[$i]} ))
    	    done
	    Sum_Prev=$(( Sum - ${Input[$(($1 - 1))]} ))
	fi
	
	# Found better
	[[ "$Sum" -gt "$Max_Value" ]] && \
        Max_Value=$Sum && \
	Max=$1

	echo2 Sum : $Sum
}

Maximize () {

	[ "$1" -gt "${#Input[@]}" ] \
     && return 0 
		
	Sum_Curr $1
	read q

}

Case_0 () {

	Val1=${Input[$(($1 - 1))]}
	Valn=${Input[$(($1 + n - 2))]}
	
	# When 0 in serie, we skip it 
	#   ( actually them... )
	if [[ "$Val1" -eq "0" ]]
	then
		echo2 Skipping 1..
		Sum=0
		Sum_Prev=0
		Maximise $(($1 + 1)) 
		i=$(($1 + 1))
		return 0
	fi
	# When 0 in serie, we skip it 
	#   ( actually them... )
	if [[ "$Valn" -eq "0" ]]
	then
		echo2 Skipping N..
		Sum=0
		Sum_Prev=0
		Maximise $(($1 + n)) 
		i=$(($1 + n))
		return 0
	fi	
}

display () {

    if [[ "$Sum" -gt "0" ]] 
    then
	    for i in $(seq $(($Max - 1)) $((Max + n - 2)))
    	    do
	    Val=${Input[$i]}
	    #[[ $DEBUG -gt 0 ]] && echo -n "$Val "
    	    echo2 "-n" "$Val "

#  not required and time consuming (though..)
            Prod=$((Prod *= Val)) 
            done
    else
    :
    fi

    echo2 ")"
    echo2 "SumMax : $Max_Value"
    
    echo2 "Product : $Prod"
    echo "$Prod"
}


main () {

    test_params "$@"

    i=1

    echo2 $Input_Length
    while [[ "$i" -le "$((Input_Length - n + 1))" ]]
    do
	    Case_0 $i
	    Maximize $i
	    ((i+=1))
    done

# My Prefered display but not fitting tests in .bats 
    #[[ $DEBUG -gt 0 ]] && echo -n "Optimal is ( "
    echo2 "-n" "Optimal is ( "

    display
    
    exit 0
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
exit 99

