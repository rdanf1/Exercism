#!/usr/bin/env bash
# DR - Ascen+18 - 2025
#
# Maths :
#
#   I dunno..
#   	though conclusion is :
#   	   .. so 4/2 is 2 and 2/2 is 1 !
#
# for any N :
#   odd  : (N*2 + 1)*3 +1 = 6N + 4 = (3*N + 2)/2 = pair [1]
#   pair :  N/2                                         [2]
#
#   So from odd (N*2 + 1)  after 2 iterations 
#   we get      (N*3 + 2) that can be odd or pair [3]
#
#   if N is pair / n*2=N then after another iteration
#   we get      (n*3 + 1) that can be odd or pair
#
#   if N is odd / N=(n*2 + 1) [3]=> 6n + 4 = (3n + 2)/2 P
#   after 3 iterations we get (3n + 2) TCB odd or pair...
#   
#   => Seems recurrent but difficult to prove/apply !!!
#
#
#	ANOTHER APPROCH :
#
#   Oh ! But reciprocity may be instructive
#   if we suppose conjecture is true then
#   recpprocity (R) may apply :
#
#   from number 1, reach any integer number applying,
#
#     these 2 rules (r1 & r2) :
#
#           [r1] if possible on ℕ (and not an exeption,
#                                  see below..) 
#                   substract 1 and divide by 3
#              
#           [r2] if not [r1] then multiply by 2
#
#   Doing so, we may parse ℕ (all integers)
#   and finally reach our number K in k iterati@ns !!!
#
#   So maybe reciprocity gives a partial response
#   if we can prove that [r1] [r2] for ℕ
#                  Resp. [f2] [f1]       
#   is an equivalent of (n + 1) scheme to browse ℕ [*]
#   then we are good !
#   => That's the interesting part : plain ℕ constructors
#
#   Meanwhile we'll implement [r1] [r2]  (R) 
#   for reaching K 
#     ( and many of its predecessors in Olano's ℕ )
#
#   And we may *additionally* count our parsing to K
#   so we could conjecture that *around* K iterations 
#   are needed to reach K !
#
#   Ends Maths
#
# 1227                :: 132 iterati@ns
# 1227000001          :: 157
# 1227000001123456789 :: 293
# 122712345678911234  :: 437
# 1333333379          :: 364 !!!
#
# NB : Removing printf2 makes faster results !!
#
#########################################################
#
#  AFTER "PRACTICING" A SCHEME COULD BE Choosen :
#   for reconstruction from scratch of n 
#   using r[1,2] and an additional array of r2 exceptions
#
#
#   We keep only exceptions 0. (collected in fw mode) : 
#
#     0. when r2 was indeed apply-able but wasnt applied
#          => apply r1 [no need to re-compute possible r2]
#          = tagged cases !
#
#     1. else apply r2 when possible (n-1)*3 [compute]
#                            (sum digits: three_division)
#     2. r1 is applied (n*2)
#
#   TODO : rr[] > restricted reverse table
#              wich contains only r2 exceptions (hops!)
#                          + regulars consecutives r2
#     for example starting to n=1 -> !r2=r1 1*2=2  h
#                               2 -> r1     2*2=4  -
#                               4 -> !r2=r1 4*2=8  h
#                               8 -> r1     8*2=16 -
#                              16 -> r2 (16-1)/3=5 1
#     So 5 is equal to rr[1]={h,h,1r}={2h,1r}
#              2 (consecutives) r2 hops + 1 regular r2
#
#     So 8 is equal to rr[1]={h,h,1}={2h,1}
#                             2 r2 hops + 1 regular r1
#
#              > we do not need to know k (nb iterations)
#                if we know nb of r2 exceptions 
#                and last regulars r2 and r1 if any !!!
#                in other words :
#
#  ------------------------------------------------------  
#                                         (if any !)
#  A serie : nb_of_exceptions_to_r2 (+ nb_of_regular_r2
#                                    + nb_of_regular_r1).
#
#  with 2 reverse rules r[1,2] is a bijection to ℕ.
#        
#  ------------------------------------------------------  
#
#  OTHERS PATHS                <======= f^k ==========>
#      S(n)=Serie of numbers / n --> f(n) --> f(f(n))..
#          =Collatz Serie (forward mode..)
#
#         - Get Max[n] when parsing S(n)
#         - Create ensemblist theory ∀n / n ∈ S(n)
#         - Cryptography/Codes/Compression issues..
#      Games
#         - Greatest k for smallest n, etc...
#                 
#  -----------------------------------------------------   
#
#  PRACTICALLY IN REVERSE MODE LAST 2 ITERATIONS :
#   ( we choosed 133333 for n that takes 131 iterations )
#
#   r@ is set of rules to apply in reverse r[1]:last 
#      ( =0 r2 or =1 r1 ) collected in "forward" mode..)
#   last Val=n
#

SAMPLE=$(cat <<END_SAMPLE
Reversing from : 200000
Val :  400000
r@ :  0 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 0 1 0 1 0 1 1 1
 0 1 0 1 0 1 0 1 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 1 0 1 0 1 0
1 0 1 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1
 0 1 1 1 0 1 0 1 0 1 0 1 1 1 1 0 1 1 0 1 1 0 1 1 1 1 0 1 1
1 0 1 0 1 0 1 1 1 1 1 0 1 1 1 1
ri :  0

Reversing from : 400000
Applying : r2
Val :  133333
r@ :  0 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 0 1 0 1 0 1 1 1
 0 1 0 1 0 1 0 1 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 1 0 1 0 1 0
1 0 1 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 1 0 1 0 1 0 1 0 1 0 1
 0 1 1 1 0 1 0 1 0 1 0 1 1 1 1 0 1 1 0 1 1 0 1 1 1 1 0 1 1
1 0 1 0 1 0 1 1 1 1 1 0 1 1 1 1
ri :
END_SAMPLE
)

# Debug mode [ mainly  for echoes from
#             'printf2 function' >1 => echo
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
#    Usage: printf2 "<echo param>" "<values..>"
#
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		printf '%s\n' "$*"
	fi
	# Always true
	return 0
}


# Functions

test_params () {

	# for grep :   escapes 
	#            & quotes  in grep arg
	# 1 Number between 1 to ls(2 ** 63 - 1) => Ok !
	#  ls:long signed       lu(2 ** 64 - 1)
	#  lu:long unsigned
	#
	# nb : no escape before '*' !
	#
	REGEX_PARAMS='^\([1-9]\)\([0-9]\)*$'

	# for =~ comparison : no escapes 
	#                     no quotes in [[..]]
	#
	# Ok : 10 or 1-9 x 2 (2d value optionnal)
	#
	REGEX_PARAM2='^([1-9])([0-9])*$'

	# No Need to develop args : "$*" 
	#
	# nb: debug printf2 != printf !! 
	#     in function $@->$*  => args ok 
	#
	#Input="$(printf2 "$@" | xargs)"

	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	# At least : MORE ! (Master of Reg. Expr!)
	#  [ Deep // tests.. ]
	#
	printf2 "$Input" | grep "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ $Input =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! $Input =~ $REGEX_PARAM2 ]]
	then
		printf2 "Imput Wrong Regex"
		printf \
	"Error: Only positive numbers are allowed\n"
		exit 3
	else
# some tests
printf2 ":#->${Input}" ; printf2 ":keys->${Input@k}"
printf2 ":#->${#Input}" ; printf2 ":keys->${!Input}"

	        printf2 "Imput Ok 1 number"
		return 0
	fi
}

# Sum of digits
three_division () {

    Val="$1"
    j=0
    #printf2 "Val 01 : " "${Val:0:1}"
    #printf2 "Val 01 : " "${Val:1:1}"
    #printf2 "Val 01 : " "${Val:2:1}"

    for i in $(seq 0 $((${#Val} - 1)) )
    do
	    j=$(( j + "${Val:$i:1}" ))
	    #printf2 "j : " "$j"
    done

    #printf2 "Sum of digits of" "$Val" "is : " "$j"
    return $(( j % 3 ))

}

Reverse () {
	
    declare -i i="$2"
	
    #printf2 "Val : " "$1"
    #printf2 "r@ : " "${r[@]}"
    #printf2 "ri : " "${r[i]}"
    #printf2 "e@ : " "${e[@]}"

    # Uncomment for "Manual" stop..
    #read q

    j="${r[i]}"

    #printf2 "Reversing from : " "$1"

    if [[ "$1" -ne "$K" ]]
    then
	if [ "a$j" == "a1" ]
	then
	    #if three_division "$(($1 - 1))";  
	    #then
		 # Tricky with indice notation
		 #   => avoid it.. 
	    # 	 e+=( "1" )
		 #printf2 "r1 but r2 possible.."
	    #else
	    # 	 e+=( "0" )
	    #fi
	    # Implicitly r1 if not (r2)
	    Reverse "$(($1 * 2))" "$(($2 - 1))"
     	else
	    #e+=( "0" )
	    #printf2 "Applying : r2"
	    Reverse "$((($1 - 1) / 3))" "$(($2 - 1))"
	fi
    else
	    #printf2 "The Final number is : " "$1"
	    #printf2 "Number of iterations is : " "$k"
	    printf "The Final number is %s \n" "$1"
    fi
}

Reverse_Hops () {
	
    declare -i i="$2"
	
    #printf2 "Val : " "$1"
    #printf2 "e@ : " "${e[@]}"
    #printf2 "ei : " "${e[i]}"

    # Debug Stop mark
    #printf2 "<Enter> required Plz"
    #[[ $DEBUG -gt "1" ]] && \
    #read q

    j="${e[i]}"

    #printf2 "Reversing from : " "$1"

    # Terminal Condition : 
    #         there is a value to read in e[]
    #
    if [ "a$j" != "a" ]
    then
	if [ "a$j" == "a1" ]
	then
	    # Exception occurs
	    #printf2 "r2 exept. r1 applied.."
	    Reverse_Hops "$(($1 * 2))" "$(($2 + 1))"
	else
	    # No exception => check r2
	    if three_division "$(($1 - 1))";
	    then
		#printf2 "r2 possible r2 applied.."
	        Reverse_Hops "$((($1 - 1) / 3))" "$(($2 + 1))"
	    else
	        Reverse_Hops "$(($1 * 2))" "$(($2 + 1))"
	    fi
	fi
    else
	    #printf2 "The number is : " "$1"
	    #printf2 "Number of iterations is : " "$k"
	    printf "The number is : %s\n" "$1"
    fi
}

Recite () {
     
    declare Val="$1"

    #printf2 "Iterate nb : " "$1"

    # End Condition
    if [[ "$Val" -eq "1" ]]
    then
	    #printf2 "Value of k is : " "$k" && \
	    printf "%i\n" "$k" && \
	    return 0
    else

    	    Resp_Rule1="$(( $1  % 2 ))"
    	    #printf2 "Resp_Rule1 : " "$Resp_Rule1"

    	    if	[[ "$Resp_Rule1" -eq "0" ]]
    	    then
    		((k++))
		r[k]="1"
 		Recite "$(( $1 / 2 ))"
    	    else
    		((k++))
		# not needed implicit > no..
		r[k]="0"
		Recite "$(( $1 * 3 + 1 ))"
    	    fi
    fi
}

main () {

    # Input, Iterations
    declare -i Input=0 k=0

    # to store way back from 1
    #    ( r(0)=0 1st iteration was K/2 
    #   or r(0)=1 1st iteration was 3*K + 1
    #
    declare -a r=( )

    # Exceptions to r2
    declare -a e=( )

    # Test arguments
    test_params "$@"

    K="$Input"

    # Process
    Recite $K
    #time Recite $K
    exit 0

    #printf2 "r@ : " "${r[@]}"
    #read q

    time Reverse 1 $k
    
    printf2 "e@ : " "${e[@]}"

    Reverse_Hops 1 0 

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

