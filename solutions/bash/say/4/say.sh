#!/usr/bin/env bash
# DR - Ascension+64 - 2025
#
# Notes : 
# 	slowest program *ever*
# 	espeak isnt very fast even with -q
# 	numerous arrays (..1 are useless)
# 	=> translations from espeak --ipa isnt optimum !
#
# Notes V2 ( without espeak.. ) :
#
#       1. Solve for 3 digits groups (hundreds max: 999)
#
#       2. "In-between" : 
#          Add thousands, millions, etc..
#

# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0


# Debugging
#
#    Usage: printf2 "<var descr.> :" "<var>"
#
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		if [[ "$1" =~ '%' ]]
		then
			printf "$@"
		else

		        printf '%s\n' "$*"
		fi

	fi
	# Always true
	return 0
}

say_3 () {
    local arg1="$1"
    arg1="${arg1// /}"
    while [[ ${arg1:0:1} -eq 0 ]] 
    do
        arg1="${arg1:1}"
    done
    #arg1="$(echo "$arg1" | sed 's/^00//')"
    #arg1="$(echo "$arg1" | sed 's/^0//')"
	     printf2 "avant tout %s " "$arg1"
    while [[ "${#arg1}" -ne 0 ]]
    do
	case "${#arg1}" in
	   3)
	     input="${arg1:0:1}"
	     printf2 "\navant3 %s \n" "$input"
	     #read q
	     for i in {0..9} 
	     do
	input="${input//${Units1[i]/ */}/ ${Units1[i]/* /}}"
	     done
	     printf "%s %s" "$input" "hundred"
	     #read q
	     ;;
	  2)
	     input="${arg1:0:2}"
	     printf2 "\navant2 %s \n" "$input"
	     #read q
	     [ "$arg1" == "00" ] && break
	  if [ "${arg1:0:1}" -le 1 ] # Tens <= 19
	  then
	for i in {0..9}
	do
	  input="${input//${Ele01[i]/ */}/ ${Ele01[i]/* /}}"
	  input="${input//${Eles1[i]/ */}/ ${Eles1[i]/* /}}"
  	done
	printf "%s" "$input"
	break
	  else                 	     # Tens > 19
	input="${arg1:0:1}0"
	for i in {0..7}
	do
	  input="${input//${Tens1[i]/ */}/ ${Tens1[i]/* /}}"
  	done
	printf "%s" "$input"
	  fi
	     ;;
	  1) 

	     input="$arg1"
	     printf2 "\navant1 %s \n" "$input"
	     #read q
	     [ "$arg1" == "0" ] && break
	     for i in {0..9} 
	     do
	input="${input//${Units1[i]/ */}/ ${Units1[i]/* /}}"
	     done
	     printf "%s" "$input"
	     ;;
	   *)
	     printf2 "wrong size arg1: " "$arg1"
	     ;;
	esac
	arg1="${arg1:1}"
	printf2 "\narg1 : %s" "$arg1"
	     #read q
    done
}

huge_func () {

[[ "$1" -lt 0 ]] && echo "input out of range" \
		 && exit 1
reg='^[0-9]+$'
[[ ! "$1" =~ $reg ]] && echo "not natural number input" && exit 2
[ "$1" == "0" ] && echo "zero" && exit 0

# Comment this line to improve range limit !
#    (espeak is ok with 9*10^30 = 9 nonellions)
#
[[ "${#1}" -ge 13 ]] && echo "input out of range" && exit 3
#
#[[ "${#Inp}" -gt 31 ]] && echo "input out of range" && exit 3


# Making some useful arrays :
#

# not sure if many (plurals) => ..s ?
#declare -a Thousand2=(thousands millions billions \
#trillions quadrillions quintillions sextillions septillions \
#octillions nonillions)
declare -a Thousand2=(thousand million billion \
trillion quadrillion quintillion sextillion septillion \
octillions nonillions)
declare -i th2_i=0

Thousands="$(\
	for i in {3..30..3} ; do Nb="$(bc <<<10^$i)" ; printf "%.0f " "$Nb" ; printf ' %s\n' "${Thousand2[th2_i]}" ; ((th2_i++)) ; done
)"

declare -a Thousands1=( )
while read -r i j
do
	Thousands1+=( "$i $j" )
done < <(printf "%s\n" "$Thousands")

printf2 "Thousands1 : %s\n" "${Thousands1[@]}"
#printf2 "%s\n" "${Thousands2[@]}"

declare -a Ten2=(twenty thirty forty fifty \
sixty seventy eighty ninety)
declare -i t2_i=0

Tens="$(\
	for i in {20..90..10} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf ' %s\n' "${Ten2[t2_i]}" ; ((t2_i++)) ; done
)"

declare -a Tens1=( )
while read -r i j
do
	Tens1+=( "$i $j" )
done < <(printf "%s\n" "$Tens")

printf2 "Tens1 : %s\n" "${Tens1[@]}"

declare -a Unit2=(zero one two three four five \
six seven eight nine)
declare -i u2_i=0

Units="$(\
	for i in {0..9} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf ' %s\n' "${Unit2[u2_i]}" ; ((u2_i++)) ; done
)"

declare -a Units1=( )
while read -r i j
do
	Units1+=( "$i $j" )
done < <(printf "%s\n" "$Units")

printf2 "Units : %s\n" "${Units1[@]}"

# 01..09 :
#   => peculiar units on 2 digits
#
declare -i e0_i=0
Elev="$(\
	for i in {00..09} ; do Nb="$i" ; printf "%s " "$Nb" ; printf ' %s\n' "${Unit2[e0_i]}" ; ((e0_i++)) ; done
)"

declare -a Ele01=( )
while read -r i j
do
	Ele01+=( "$i $j" )
done < <(printf "%s\n" "$Elev")

printf2 "Ele01 :%s\n" "${Ele01[@]}"

declare -a Ele2=(ten eleven twelve thirteen fourteen fifteen \
sixteen seventeen eighteen nineteen)
declare -i e2_i=0

Eles="$(\
	for i in {10..19} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf ' %s\n' "${Ele2[e2_i]}" ; ((e2_i++)) ; done
)"

declare -a Eles1=( )
while read -r i j
do
	Eles1+=( "$i $j" )
done < <(printf "%s\n" "$Eles")

printf2 "Eles1 :%s\n" "${Eles1[@]}"
#printf2 "%s\n" "${Eles2[@]}"

#declare Hund1="\[0-9\] hundred"
#declare Hund1="$(espeak --ipa -q 100 \
#	       | sed 's/wˈɒn//g') hundred"

# ipa 'and' of espeak based 1st $0 version..
#declare And2="ən and"

# "espeak" can do the job if installed..
#    ( translate from ipa.. )
#
#Input="$(espeak -q --ipa "$s")"

Input="$1"

printf2 "Input :" "$Input"


	Input3="$(printf "%s" "$(echo "$1" \
			| rev \
			| sed -E 's/(...)/ \1 /g' \
			| tr -s ' ' | rev)")"
	Input4="$Input3"

	Initial_size="${#1}"
	printf2 "Initial_size :" "$Initial_size"

	for i in {30..3..-3}
	do
	    if [[ "$Initial_size" -gt "$i" ]]
	    then 
		thousands+="$(printf "%s " "${Thousand2[i/3-1]}")"
	    fi
    	done

	printf2 "thousands :" "$thousands"
	
	
	for i in $thousands
	do
		Input3="$(echo "$Input3" \
		| sed -E "s/([0-9]) ([0-9])/\1 $i \2/")"
	done

	#echo "$Input3"| sed -E 's/([a-z]) /\1\n/g'
	#
	# The really hard stuff !!!!!!!
	#  ( make good pairs for each line )
	#
	Input5="$(echo "$Input3"| sed -E 's/([a-z]) /\1\n/g')"

# return to previous Input3
#  remove all but spaces & digits
#  => 2 spaces to shrink with tr
#
#echo "${Input3//[^0-9 ]/}" | tr -s ' '

	printf2 "Input4 :" "$Input4"
	printf2 "Input3 ::::::::::::::::::::: %s" "$Input3"

	#say_3 "$Input4"	
	result=""

	while read -r i j
	do
		if [ "$i" == "000" ]
		then
			continue
		fi
		if [ "$i" == "00" ]
		then
			continue
		fi
		#i=$(printf "%s" "$i")
		#say_3 "$i"
		#j=$(printf "%s" "$j")
		printf2 "\niiiiiiii %s " "$i"	
		printf2 "jjjjjjjj %s\n" "$j"	
		result+="$(echo -n "$(say_3 "$i") $j ")"
	done < <(IFS=$'\n' echo "$Input5")

	result="$(printf "%s\n" "$result" | tr -s ' '    \
	                        | sed 's/^ //' \
				| sed 's/ty /ty-/g' \
				| sed 's/ty-$/ty/')"

	printf2 "\nresult : %s\n" "$result"
	printf "%s\n" "$result" | sed 's/ $//'

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
     # because sometimes we use '-' as a non-option argument

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
		        return 2
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
	#  conforms with => Cf @test outputs needed
	#
REGEX_PARAM=\
'[ -~]\+'
REGEX_PARAMM=\
'[0-9]\+[0-9]*'
REGEX_PARAMS=\
"^$REGEX_PARAM$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM1=\
'[ -~]+'
REGEX_PARAM2=\
"^$REGEX_PARAM1$"

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

	    # Here remaining args after options
	    #
	    # Shorter way to browse args :
	    for arg
	    do
	     	  printf2 "arg :" "$arg"
	    done
	    #
	    # If specific args values to check
	    #  use case :	 
	    #case "$1" in
	    #    0) echo "$1 is 0"
	    #	       shift
	    #	       ;;
	    #	    *) echo "never happens"
	    #		return 5
	    #		;;
	    #esac 

	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}


main () {
 
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
	    0)
		huge_func "${Input[@]}"
		    ;;
	    *)
		huge_func "${Input[@]}"
		printf2 "An Invalid Input Occurred"
	        #exit 1 
		#    ;;
    esac

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

