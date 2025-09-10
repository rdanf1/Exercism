#!/usr/bin/env bash
# DR - Ascension+57 - 2025
#
# Maths
#
#  see @Readme.md
#
#  My implementation uses 'factor' for reducing
#       and a heron's bc script for nth root (rpow case..)
#
# Todo :
#        Trap on time extended (rpow & bc..)
#        Process management
#        Errors
#        Special opti@ns :
#           - Full display (decimals)
#           - ..
#

# We use some temporary files..
#  ( getting default path for them )
#
TmpDir="${TMPDIR:=.}"

# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0

# Debugging
#    Usage: printf2 "<var descr.> :" "<var>"
#
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		# if no format => string
		if [[ ! "$1" =~ '%' ]]
	        then
			printf '%s\n' "$*"
		else
		# format as regular printf
			printf "$@"
		fi
	fi
	# Always true
	return 0
}

# This is a bc script file
#   ( used to compute nth root of an integer or
#   				  a  decimal )
cat <<End_root > "$TmpDir/root.bc"
scale = 0
a = 9 
n = 2

print "Value to sqrt? "; a = read()
print "Level of sqrt? "; n = read()
print "Nb of iterations? (7-11)"; q = read()

# added peculiar case with a negative & n odd..
#   ( isnt it ?!.. )
#
if ( a < 0 ) { neg = 1 } else neg = 0
if ( n % 2 == 1 ) { nod = 1 } else nod = 0
if ( neg == 1 && nod == 1 ) neg_nod = 1 else neg_nod = 0

# dont use quit ( cf man bc.. )
if ( neg == 1 && neg_nod == 0 ) { print "\nnb positive for pair root"; print "\n-1"; halt }
	
if ( neg_nod == 1 ) a *= -1

start = a / (n^2)
start = a / (n^2)

print start, "\n"
#print "\n"
# comment : an exp less..
#print start^n,"\n"
#print "\n"

while ( start^n > a ) start /= 2 
# comment : an exp less..
#print start^n,"\n"

# Keep this to 0.01 for *HUGE* 
#                    *accuracy* ( 0.03 is very good too, 
#				  not 0.5 or > )
# Limits : 99      at 201 th root !
#          0.00009 at 301 th root !
#
while ( start^n < a ) start += 0.01
# comment : an exp less..
#print start^n,"\n"

print "starting with :", start, "\n"

# Found here :  https://en.wikipedia.org/wiki/Nth_root
#  ( heron's for nth root )
#
define rt_guess (x) {
if (x <= 1) return (start);
return (rt_guess(x-1)*((n-1)/n) + (a/n)*(rt_guess(x-1)^-(n-1)))
}

scale = 25 

# ie q=10 iterations : *VERY MUCH* accurate ! 
#
nth_root = rt_guess(q)

#scale = 0
#print "m : ", m, "\n"
#scale = 25
#if ( m == 1 ) nth_root += 0.0000000000000001

#nth_root += 0.00000000000000000000001

if ( neg_nod == 1 ) nth_root *= -1

print "nth_root: ",  nth_root
print "\n"
print "nth_root^n : ",  nth_root^n
print "\n"
print "a : ", a
print "\n"
print "n : ", n
print "\n"
print "q : ", q
print "\n"
print "nth_root^n : ", nth_root^n
print "\n"
print "nth_root^-1: ", nth_root^-1
print "\n"

# Check accurracy ( if << 100 >> not accurate.. )
#
# no neg cf nth_sqrt ()
if ( neg_nod == 1 ) nth_root *= -1
print "nth_root^n/a : ", (nth_root^n/a)*100, "%\n"
print "\n"

quit
# how to use this bc file in bash :
#
$ echo 9$'\n'89$'\n'3 | bc -q nth_sqr.bc
End_root

#cat root.bc

# Compute Nth root of a number : used only for rpow..
# 		( mainly with bc & root.bc )
#   args : 
#   		1. Positive Integer or decimal (to find nth root)
#   		2. Ntn root n to apply to $1
#   		3. Initial number of iteration (1-12)
#
nth_sqrt () {
trap 'date; echo "Compute Time exhausted.."; return 11' USR1

     # Calculations are done using powerful 'bc'.
     # 		( see file root.bc above 
     # 		  using heron's algorithm
     # 	  found here :  https://en.wikipedia.org/wiki/Nth_root
     #
     #			# echo "$1" $'\n' "$2" $'\n' "$3" 
     #
     # & sends bc (and sleep) as running job..
     #
     results=$(echo "$1" $'\n' "$2" $'\n' "$3" | bc -ql root.bc)

     err='nb positive for pair'
     [[ "$results" =~ $err ]] \
  && echo 'Nb positive for pair root' && exit 254

     # un-comment to see full results in debug mode
     #  ( contains % accuracy value too )
     #
     #printf2 "results : %s\n" "$results"
     #printf2 "full result : %s\n" $(echo  $results \
#	     		| sed 's/.*nth_root: //' \
#			| sed -E 's/(\.[0-9]*).*/\1/' \
#			| sed 's/^\./0\./')

     # Strict conditions : less than ±0.000001 % error
     #                     retry with +1 iteration
     # using reverse operation = ( X^n ) / A
     #       part in results to check result % accuracy
     #
     # nb : comparisons are done between strings with '=='
     #               ( bash dont know decimal numbers.. )
     # nb2: do *NOT* double quote $results
     #
     # output: conforming with peculiars rpow @tests to pass
     #      - 6 precision digits decimals.. (bc do 4x more)
     #        => not enough in most cases except when trivial 
     #        repetitives decimals or integer results.
     #      - 1 digit with .0 decimal if integer returned.. (?)
     #
     [ ! "$(echo $results | sed 's/.*nth_root^n\/a : //' \
	     | sed -E 's/(\.[0-9]{2,6}).*/\1/')" == \
	     "100.000000" ] \
  && [ ! "$(echo $results | sed 's/.*nth_root^n\/a : //' \
	     | sed -E 's/(\.[0-9]{2,6}).*/\1/')" == \
	     "99.999999" ] \
  && nth_sqrt "$1" "$2" "$(($3 + 1))" \
  || echo  $results	| sed 's/.*nth_root: //' \
			| sed -E 's/(\.[0-9]{2,6}).*/\1/' \
			| sed -E 's/\.[0]{2,6}$/\.0/' \
			| sed 's/^\./0\./' \
			| sed 's/^-\./-0\./' > "$TmpDir/Out.tmp"
}

test_zone () {

# some unary tests
#  of function above..
#  and .. 
#         "Time exceeded" implementation
#
#nth_sqrt "22986" "2" "1"
#nth_sqrt "0.00009" "39" "9"
#nth_sqrt "-0.00009" "39" "9"
#nth_sqrt "9" "139" "9"
#nth_sqrt "-0.00009" "139" "11"
#nth_sqrt "8" "3" "1"
#nth_sqrt "9" "2" "1"
# should not work if less than 11 iterations
#   ( for less than ±0.000001 % error 
#                   +0.00000000002 actually! :)
#
#nth_sqrt "0.00009" "119" "9"

# Repport batch changes
#   immediately..
set -b

# sleep is our timeout program
#  cleaning..
#
killall sleep 2>/dev/null

trap 'echo received TERM ( or HUP, QUIT, ABRT ) signal, \
cleaning...; \
rm "$TmpDir/Out.tmp" "$TmpDir/root.bc" 2>/dev/null; \
exit 11' TERM HUP QUIT ABRT

rm "$TmpDir/Out.tmp" 2>/dev/null

# This is our timeout job..
#  (pid stored in slp var)
#
sleep 15 &
slp="$!"

# Check time if debug mode
#    before launch of (long?) job cmd..
#
[[ DEBUG -gt 0 ]] && date

# This is our 'eventually long' job..
#   ( pid is stored in nth var )
#
nth_sqrt "9" "58" "15" &
nth="$!"

# Some debug
printf2 "$(jobs -lr)"
printf2 "nth: $nth"

# Waiting whether sleep or nth_root
#   termination (assuming 2 jobs running..)
#
if wait -n # && echo "time extended1"
then
	kill -12 "$nth" 2>/dev/null \
     && killall bc      2>/dev/null \
     || kill -15 "$slp"
else
	printf2 "All jobs terminated.."
fi

# Displaying results (if any)
#    "batched nth_root" 
#          => sends results to a temporary file 
#       or was interrupted with kill -USR1
#
cat "$TmpDir/Out.tmp" 2>/dev/null
rm "$TmpDir/Out.tmp" 2>/dev/null

exit

}


# Functions

store_Opts () {
	
	# Manage options
	#    getopt sorts input vars
	#       1. options and their values if any
	#       2. '--' ( separator = end of options )
	#       3. other arguments
	
	# -x as extended parameter (or none..)
	#
	{ ! TEMP0=$(getopt -Qq -o 'x' -n "$0" -- "$@") ;} \
     && printf2 'getopt error...' >&2 \
     && return 1
     #&& exit 1
     # ^^^^^^^^ error is non-terminate-condition
     # because we use '-' as a non-option argument

	printf2 "TEMP0 :" "$TEMP0"

	# Note the quotes around "$TEMP": they are essential!
	#  sets getopts results in $1..$n positionnal args
	#  with 1st options and their values then '--'
	#                        then non-option args.
	eval set -- "$TEMP0"

	# used in another func. (& declared in main)
	#unset TEMP0

	# Purpose is to store options
	#  not to apply them
	#
	while true
	do
	    case "$1" in

		# All chars like '-'* (exept '--'!)
		# are option switchs
		#
		'-'[^-]) # adds option in associative
			#  array Opts and affects 1
			#  (if any value plz affect
			#      value after shift!)
			#
			Opts+=( [${1/-/}]=1 )
			printf2 "!Opts :" "${!Opts[@]}"
			shift
			continue
			;;
		# Reached the end of options
		#  => exiting while loop
		#
		'--') 	shift
			break
			;;
		# Any other values
		#   => never happens
		#      => happens if getopt error..
		#         => then 'return 1' above  
		#            => never happens !
		*) 	
			printf2 'Opts Internal error!' >&2
		#         continue..
		        return 2
			#break
			#exit 2
			;;
	    esac
	done
}


store_Input () {

	store_Opts "$@"

	# Remaining arguments
	#
	#     <=> $arg1 $arg2 .. $argn
	#
	while [[ "$#" -gt 0 ]]
	do
	    Input+=( "$1" )
	    Input2+=" $1"
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
	    Input2="${Input2:1}"
	    printf2 "Input2 :" "$Input2"
}

# Figure out (using regex) if input shape is 
#                 as required/correct
#
test_regex () {

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with
    	#   "Usage : $0 <opts..> <string> <files..>"
	#
REGEX_PARAM=\
'\(+\|-\|*\|/\|abs\|pow\|rpow\|reduce\)'
REGEX_PARAMM=\
'[0-9]\+[0-9]*'
REGEX_PARAMS=\
"^$REGEX_PARAM\( $REGEX_PARAMM/$REGEX_PARAMM\)\+$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM0=\
'\-?'
REGEX_PARAM1=\
'(\+|\-|\*|\/|abs|pow|rpow|reduce)'
REGEX_PARA11=\
'[0-9]+[0-9]*'
REGEX_PARAM2=\
"^$REGEX_PARAM1( $REGEX_PARAM0$REGEX_PARA11| $REGEX_PARAM0$REGEX_PARA11/$REGEX_PARAM0$REGEX_PARA11)+$"

	#  [ Deep regex // tests.. ]
	#
	printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}


test_params () {

	# So called
	store_Input "$@"
	test_regex "$@"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #

echo "Usage : $0 <+|-|*|/|abs|pow|rpow|reduce> <rational1-2>"
echo "Usage : $0 <operand> <rational1> [<rational2>]"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0]} is the Pattern searched 
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	# Jumping after options (if any!)
	if [[ -v "$TEMP0" ]]
	then
	    # redefine positional args
	    #  ( TEMP0 was set in store_Input function )
	    #
	    eval set -- "$TEMP0"

	    #
	    # jump to "non-optionals" arguments
	    #
	    while true
	    do 
		    [ "$1" == '--' ] && break
		    shift
	    done

	    #   => files args
	    shift     # from '--' to <1st arg>
	fi
	    # Jump after <1st arg> 
	    #shift     # from <1st arg> to <2d arg>

	    # Do more checks after regex ok
	    #
	    case "$1" in
	        '+'|'-'|'*'|'/') shift

			[[ "$#" -lt 2 ]] \
		     && echo "Missing 1 arg" && exit 1

			return 1
			;;

		'abs'|'reduce') shift
			[[ "$#" -ne 1 ]] \
		     && echo "1 rational needed" && exit 2

			return 2
			;;

		'pow') shift

			[[ "$#" -lt 2 ]] \
		     && echo "Missing 1 arg" && exit 1

		     # nb : cant use PARA11 (no ^..$)
			[[ ! "$2" =~ ^-?[0-9]+$ ]] \
		     && echo "2d arg must be an integer" \
		     && exit 3

			return 3
			;;

		'rpow') shift

			[[ "$#" -lt 2 ]] \
		     && echo "Missing 1 arg" && exit 1
			
		     # nb : cant use PARA11 (no ^..$)
			[[ ! "$1" =~ ^-?[0-9]+$ ]] \
		     && echo "1st arg must be an integer" \
		     && exit 3

			return 4
			;;

		    *) echo "never happens"
			return 5
			;;
	   esac 

	# Args Ok
	#
	    #printf2 "Arguments Ok !"
	    #return 0
	fi
}

# Eiher reduce (main part)
#    or reduce then  abs !
#
mk_1_oper () {

	# This is all "reduce funct" ( always applied )
	#
	# then if abs keeps minus sign removed

	# Trivial case single digit
	#
	[[ "$2" =~ ^-?[0-9]+$ ]] \
     && echo "$2/1" && return 0

        # Split $2 in Num(erator) Den(ominator)
        #
	Num="$(echo "$2" | cut -d"/" -f 1)"
	Den="$(echo "$2" | cut -d"/" -f 2)"
	printf2 "Num :" "$Num"
	printf2 "Den :" "$Den"

	# Store minus sign (and remove it from Num & Den
	#     because factor is for positive integers)
	#
	declare -i sign=1	
	[[ "$Num" -lt 0 ]] && ((sign*=-1)) && Num=$((- Num))
	[[ "$Den" -lt 0 ]] && ((sign*=-1)) && Den=$((- Den))


	# Using factor for getting primes factors
	#
	num="$(factor "$Num" | cut -d":" -f 2- | cut -c 2-)"
	# affected below too (if simplified)
	den="$(factor "$Den" | cut -d":" -f 2- | cut -c 2-)"
	recomp_den=0

	printf2 "num :" "$num"
	printf2 "den :" "$den"

	# Browse all prime factors of Numerator
	#
	for i in $num
	do
	    # Recompute 'den' if 'Den' simplified below..
	    [[ recomp_den -eq 1 ]] && \
        den="$(factor "$Den" | cut -d":" -f 2- | cut -c 2-)"

	    # Browse prime factors of Denominator
	    for j in $den
	    do
		# If factors are equals
		# => simplify once and..
		#    need to break for next i
		#
		[[ "$i" -eq "$j" ]] \
	     && Num=$((Num / "$i")) && Den=$((Den / "$j")) \
	     && recomp_den=1 \
	     && break
     	    done
	done

	# if not abs = reduce 
	#   => keeps minus sign removed
	#
	[ "$1" != "abs" ] \
     &&	((Num*=sign))

	# Trivial 0
	#
	[[ "$Num" -eq 0 ]] \
     && echo "0/1" && exit 0

	# Result
	echo "$Num""/""$Den"

	# if DEBUG on : prints decimal value of rational
	#     (6 digits after '.')
	#
	printf2 "%0.6f\n" "$(bc <<<"scale=6;$Num/$Den")"
}

mk_2_oper () {
        # Split $2 in Num(erator) Den(ominator)
        #
	Num1="$(echo "$2" | cut -d"/" -f 1)"
	Den1="$(echo "$2" | cut -d"/" -f 2)"

        # Split $3 in Num(erator) Den(ominator)
        #
	Num2="$(echo "$3" | cut -d"/" -f 1)"
	Den2="$(echo "$3" | cut -d"/" -f 2)"

	case "$1" in 
	    '*')
		mk_1_oper "reduce" "$((Num1 * Num2))/$((Den1 * Den2))"
		;;
	    '/')
		mk_1_oper "reduce" "$((Num1 * Den2))/$((Den1 * Num2))"
		;;
	    '+')
		    mk_1_oper "reduce" "$(((Num1 * Den2) + (Num2 * Den1)))/$((Den1 * Den2))"
		;;
	    '-')
		    mk_1_oper "reduce" "$(((Num1 * Den2) - (Num2 * Den1)))/$((Den1 * Den2))"
		;;
	esac
}

mk_pow () {

        # Split $2 in Num(erator) Den(ominator)
        #
	Num1="$(echo "$2" | cut -d"/" -f 1)"
	Den1="$(echo "$2" | cut -d"/" -f 2)"

	if [[ "$3" -gt 0 ]]
	then
	    mk_1_oper "reduce" "$((Num1 ** $3))/$((Den1 ** $3))"
        else
	    abs="${3/-/}"
	    mk_1_oper "reduce" "$((Den1 ** abs))/$((Num1 ** abs))"
	fi
}

mk_rpow () {

        # Split $3 in Num(erator) Den(ominator)
        #
	Num1="$(echo "$3" | cut -d"/" -f 1)"
	Den1="$(echo "$3" | cut -d"/" -f 2)"
	sign=$((Num1 * Den1))

	[[ "$sign" -eq 0 ]] \
     && echo "1.0" && exit 0

	#printf2 "sign : " "$sign"

	num1="$(bc -lq <<<"$2^$Num1")"

	#printf2 "num1 : %s" "$num1"

	nth_sqrt "$num1" "$Den1" 1
}

Clean_Tmp_Files () {

    #  clean
    #
    rm "$TmpDir/root.bc" 2>/dev/null
    rm "$TmpDir/Out.tmp" 2>/dev/null
}
    	

main () {

    #test_zone ;


    # Vars filled in store_Input() 
    #    called by test_regex()
    #        called by test_params()
    #
    declare TEMP0=""
    declare -A Opts=( )

    # non-opt args
    declare -a Input=( )

    # Flat string version
    declare Input2=""

    # Test arguments
    test_params "$@"

    # Process 
    #   (depends on test_params return value)
    #
    case "$?" in
	    1)
		mk_2_oper "${Input[@]}"
		    ;;
	    2)
		mk_1_oper "${Input[@]}"
		    ;;
	    3)
		mk_pow "${Input[@]}"
		    ;;
	    4)
		mk_rpow "${Input[@]}" && \
		cat "$TmpDir/Out.tmp"
		    ;;
	    *)
		Clean_Tmp_Files
		printf2 "An Invalid Input Occurred"
	        exit 1 
		    ;;
    esac

    Clean_Tmp_Files

    exit 0
}


# Call main with all of the positional arguments
   main "$@"


