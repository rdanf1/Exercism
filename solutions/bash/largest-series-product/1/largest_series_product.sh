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
  
Max=0
Max_Value=0
Sum_Prev=0

# Functions

test_params () {

        [ "$#" != "2" ] \
     && echo "At least 2 parameter needed" \
     &&	echo "Usage: $0 <input digits> <span size>" \
     && echo exit 1 && exit 1
     #&& exit 1
     echo 1 passed

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo "Usage: $0 <input digits> <span size>" \
     && echo exit 2 && exit 2
     echo 2 passed

     #  Here we know there is 2 parameters 
     #  both are numbers and $2 < 99

       [[ $1 -lt $2 ]] \
    && echo "First Argument must be greater than 2d" \
    && echo exit 3 && exit 3
    echo 3 passed

       [[ $2 -eq 0 ]] \
    && echo "2d Argument must be greater than zero" \
    && echo exit 4 && exit 4
    echo 4 passed


    # Sub array length of Input to maximize
    Span_Length="$2"
    n=$Span_Length
    
    # An array of chars
    Input=( $(echo "$1" | sed -s 's/./& /g') )
    Input_Length="${#Input[@]}"

       [[ "${#Input[@]}" -lt "$(($Span_Length))" ]] \
    && echo "Sorry : Length of span must be less \
                     than length of Input values" \
    && echo exit 5 && exit 5
    echo 5 passed

    echo Input : ${Input[@]} Length : $Input_Length
    echo
    echo Span Length $Span_Length
    echo	

    # Previous partial sum (d for digit):
    # Avoid re-computing (n-1)/n % of Sum
    #  = d[i]+d[i+1]+..+d[i+n -1]
}


Sum_Curr () {
        # We assume we already checked
	#  if Input[$1 + n] is valid and not 0
	#
	
#	[[ $(($1 + n - 1)) -gt $Input_Length ]] \
#     && return 0 

	Val1=${Input[$(($1 - 1))]}
	Valn=${Input[$(($1 + n - 2))]}
	echo Indice $1 Value $Val1
	echo Valn : $Valn
	
	if [[ "$Sum_Prev" != "0" ]]
	then
	    echo Sum_Prev : $Sum_Prev
	    Sum=$(( $Sum_Prev + $Valn ))
	    Sum_Prev=$(( Sum_Prev - $Val1 + $Valn ))
	else
            echo 1st  arg : $1 
	    echo        n : $n
            echo last arg : $(($1 + n - 2))

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

	echo Sum : $Sum
}

Maximize () {

	[ "$1" -gt "${#Input[@]}" ] \
     && return 0 

	Cur_Val="${Input[$1]}"

	# When 0, we skip it...
	if [[ "$Cur_Val" -eq "0" ]]
	then
		Maximize $(($1 + 1)) 
	else
		Sum_Curr $1
	fi

}

main () {

    test_params "$@"

    for i in $(seq 1 $Input_Length)
    do
	    Maximize $i
    done

	    printf "Optimal is ( "

	    for i in $(seq $(($Max - 1)) $((Max + n - 2)))
    do
	    printf "%s " ${Input[$i]} 
    done

    	    printf ")\n"

    echo "SumMax : $Max_Value"

    exit 0
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
exit 99

