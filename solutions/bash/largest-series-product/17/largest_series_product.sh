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
#           then a*b*c > d*e*f      [#]
#
#     [#]=Wrong assertion !!!
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
Sum=0
Prod=1
Max_Prod=0

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

        [ "$#" != "2" ] \
     && echo2 "At least 2 parameter needed" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 "exit 1" \
     && exit 1
     echo2 "1 passed"

       [ "$1" == "" ] \
    && echo  "span must not exceed string length" \
    && exit 2

       [ "$2" == "" ] \
    && echo  "span must not be empty chain" \
    && exit 2

       [[ $2 -lt 0 ]] \
    && echo "span must not be negative" \
    && exit 3

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo "input must only contain digits" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 "exit 3" && exit 3
     echo2 "3 passed"

     #  Here we know there is 2 parameters 
     #  both are numbers and $2 < 99

       [[ $2 -eq 0 ]] \
    && echo2 "2d Argument must be greater than zero" \
    && echo2 "exit 4" && exit 4
    echo2 "4 passed"

    # Sub array length of Input to maximize
    Span_Length="$2"
    n=$Span_Length
    
    # An array of chars      [n0t debug echo2 here..] 
    #                     
    Input=( $(echo "$1" | sed -s 's/./& /g') )
    Input_Length="${#Input[@]}"

	# Input chain [unlimited] and span [00-99]
        REGEX_Digits='^[0-9]+ [0-9]?[0-9]$'
        [[ ! "$*" =~ $REGEX_Digits ]] \
     &&	echo "input must only contain digits" \
     &&	echo2 "Usage: $0 <input digits> <span size>" \
     && echo2 "exit 3" && exit 3
     echo2 "3 passed"

     #  Here we know there is 2 parameters 
     #  both are numbers and $2 < 99

       [[ $2 -eq 0 ]] \
    && echo2 "2d Argument must be greater than zero" \
    && echo2 "exit 4" && exit 4
    echo2 "4 passed"

    # Sub array length of Input to maximize
    Span_Length="$2"
    n=$Span_Length
    
    # An array of chars      [n0t debug echo2 here..] 
    #                     
    Input=( $(echo "$1" | sed -s 's/./& /g') )
    Input_Length="${#Input[@]}"

       [[ "${#Input[@]}" -lt "$Span_Length" ]] \
    && echo  "span must not exceed string length" \
    && echo2 "Sorry : Length of span must be less \
                     than length of Input values" \
    && echo2 "exit 5" && exit 5
    echo2 "5 passed"

    echo2 "Input : ${Input[@]} Length : $Input_Length"
    echo2
    echo2 "Span Length $Span_Length"
    echo2	

}

Compute_Optimum () {
	
        local Product=1

	for j in $( seq "$1"  "$(($1 + n - 1))" )
	do
	    Product=$(( Product * ${Input[$j]} ))
    	done

	echo "$Product"

}

display () {

    local Maxx="$1"
    local Prodd=1 
    local Summ=0

    for i in $( seq "$Maxx"  "$((Maxx + n - 1))" )
    	   do
	       Val=${Input[$i]}

    	       echo2 "-n" "$Val " && \
		   ((Summ+=Val)) && ((Prodd*=Val))

   	   done
    	   echo2 

    echo2 "Re-computed :" 
    echo2 "       Summ = $Summ"
    echo2 "      Prodd = $Prodd"
    echo2 
    echo2 "SumMax : $Max_Value"

    echo "Max : $Max"
}

#
# --------------------------- Keeped Because Instructive --
#
#   => Sometimes Sum1>Sum2 && Prod1<Prod2 [ can check
#                                           if replace
Wrong_Assertion () {

  if [[ $1 -eq 1 ]]
  then
	# Wrong assertion executed :
	#                                    ( for * )
	#    has lesser sum thn..  v One is absorbant !
	#  ie : 6 5 7 4 7 4 // 4 9 1 9 4 9
	#    has greater prod thn..
	# 
	# Found better ?!.. [V0]          210-220 in  
	#                                  Maximize ]
	# If equals sum :: Must check..
 	[[ "$Sum" -eq "$Max_Value" ]] && \
 	Prod="$(Compute_Optimum $ind1)" && \
 	[[ "$Prod" -gt "$Max_Prod" ]] && \
        Max_Prod=$Prod && \
        Max_Value=$Sum && \
 	Max=$ind1 && \
 	[[ $DEBUG -gt 0 ]] && display "$ind1"
 
 	# If greater sum :: Must store..
 	# If Prod is greater...
 	[[ "$Sum" -gt "$Max_Value" ]] && \
 	Prod="$(Compute_Optimum $ind1)" && \
        Max_Prod=$Prod && \
        Max_Value=$Sum && \
 	Max=$ind1 && \
 	[[ $DEBUG -gt 0 ]] && display "$ind1"

   else

	
	# Found better ?!.. [V2]
	#
	Prod="$(Compute_Optimum $ind1)"
	echo2 "CalcProd: $Prod"

	[[ "$Prod" -gt "$Max_Prod" ]] && \
        Max_Prod=$Prod && \
        Max_Value=$Sum && \
	Max=$ind1 && \
	[[ $DEBUG -gt 0 ]] && display "$ind1"
  fi	
}

Maximize () {

	# Should be placed in main, though..
	#
	#                              vvvvv Whaou !!!
	[[ "$1" -gt "$((${#Input[@]} - n + 1))" ]] \
     && return 1	

	# Trying to clarify.. 
	#   ( Setting DEBUG=1 is better )
	#                        #  OK :
	ind1=$(($1 - 1))         # (Curr-1)
	indn=$(($1 + n - 2))     # (Curr-1) + (n-1)

	Val1=${Input[$ind1]}
	Valn=${Input[$indn]}
	
	echo2 "Indice $1 Value $Val1"
	echo2 "Indice +N Valn  $Valn"

	if [[ "$Sum_Prev" != "0" ]]
	then
	    Sum=$(( Sum_Prev + Valn ))
	else
            echo2 "1st  arg : $ind1"
            echo2 "       n : $n"
            echo2 "last arg : $indn"
            
	    Sum=0
	    Sum_Prev=0
	    for i in $( seq "$ind1" "$indn")
	    do
		Sum=$(( Sum + ${Input[$i]} ))
    	    done
	fi

	Sum_Prev=$(( Sum - Val1))
        
	echo2 "Sum_Prev : $Sum_Prev"
	    
	# Appart from sums peculiar calculations..
	#   ( we need Computing Prod because sometimes 
	#       lesser sums => biggers prods !)
	#  and eventually..
	#       equals sums => different prods
	# test with debug : uncomment/comment.. 
	#[[ $DEBUG -gt 0 ]] && Wrong_Assertion 1 \
	[[ $DEBUG -gt 0 ]] && Wrong_Assertion 0 \
	                   || Wrong_Assertion 0 
	
	echo2 "Sum : $Sum"
	echo2 "MaxProd: $Max_Prod"
	
	# Insure fresh restart
	Prod=0

	# Insure fresh restart from + neutral element.
	Sum=0

	[[ $DEBUG -gt 0 ]] && read q
	
}

Case_0 () {

	# Should be placed in main, though..
	#   recurrent function
	#
	[[ "$1" -gt "$((${#Input[@]} - n))" ]] \
     && return 1	

	local Val1=${Input[$(($1 - 1))]}
	local Valn=${Input[$(($1 + n - 2))]}
	
	# When 0 in end of serie, we skip it 
	#   ( actually them... )
	#
	if [[ "$Valn" -eq "0" ]]
	then
		echo2 "Skipping N.."
		Sum=0
		Sum_Prev=0
		Prod=1
		k=$(($1 + n))
	else	
	# When 0 in 1st of serie, we skip it 
	#   ( actually them... )
	#
	if [[ "$Val1" -eq "0" ]]
	then
		echo2 "Skipping 1.."
		Sum=0
		Sum_Prev=0
		Prod=1
		k=$(($1 + 1))
	fi
	fi
}

main () {

    test_params "$@"

    k=0

    echo2 "Length : $Input_Length"
    echo2 "Main n : $n"

    while [[ "$k" -le "$((Input_Length - n + 1))" ]]
    do
	    ((k+=1))
	    Case_0 $k
	    Maximize $k
    done

    echo2 "-n" "Optimal is ( "
    [[ $DEBUG -gt 0 ]] && display "$Max"
    echo2 " )"

    echo "$Max_Prod"

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#[[ $DEBUG -gt 0 ]] && exit 99

