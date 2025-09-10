#!/usr/bin/env bash
# DR - Ascension+64 - 2025
#
# Notes : 
# 	slowest program *ever*
# 	espeak isnt very fast even with -q
# 	numerous arrays (..1 are useless)
# 	=> translations from espeak --ipa isnt optimum !
#

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
		printf '%s\n' "$*"
	fi
	# Always true
	return 0
}

huge_func () {

[[ "$1" -lt 0 ]] && echo "input out of range" && exit 1

[[ ! "$1" =~ ^[0-9]+ ]] && echo "not natural number input" && exit 2
[ "$1" == "0" ] && echo "zero" && exit 0

# Comment this line to improve range limit !
#    (espeak is ok with 9*10^30 = 9 nonellions)
#
[[ "${#1}" -ge 13 ]] && echo "input out of range" && exit 3
#
#[[ "${#1}" -ge 32 ]] && "input out of range" && exit 3


# not sure if many => ..s ?
#declare -a Thousand2=(thousands millions billions \
#trillions quadrillions quintillions sextillions septillions \
#octillions nonillions)
declare -a Thousand2=(thousand million billion \
trillion quadrillion quintillion sextillion septillion \
octillions nonillions)
declare -i th2_i=0

Thousands="$(\
	for i in {3..30..3} ; do Nb="$(bc <<<10^$i)" ; printf "%.0f " "$Nb" ; printf '%s' "$(espeak --ipa -q "$Nb")" ; printf ' %s\n' "${Thousand2[th2_i]}" ; ((th2_i++)) ; done | sed 's/ wˈɒn / /g'
)"
declare -a Thousands1=( ) \
           Thousands2=( )

while read i j k 
do
	Thousands1+=( "$(echo "$i $j")" )
	Thousands2+=( "$(echo "$j $k")" )
done < <(printf "%s\n" "$Thousands")

printf2 "%s\n" "${Thousands1[@]}"
printf2 "%s\n" "${Thousands2[@]}"

declare -a Ten2=(ten twenty thirty forty fifty \
sixty seventy eighty ninety)
declare -i t2_i=0

Tens="$(\
	for i in {10..90..10} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf '%s' "$(espeak --ipa -q "$Nb")" ; printf ' %s\n' "${Ten2[t2_i]}" ; ((t2_i++)) ; done
)"
declare -a Tens1=( ) \
           Tens2=( )

while read i j k 
do
	Tens1+=( "$(echo "$i $j")" )
	Tens2+=( "$(echo "$j $k")" )
done < <(printf "%s\n" "$Tens")

printf2 "%s\n" "${Tens1[@]}"
printf2 "%s\n" "${Tens2[@]}"

declare -a Unit2=(one two three four five \
six seven eight nine)
declare -i u2_i=0

Units="$(\
	for i in {1..9} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf '%s' "$(espeak --ipa -q "$Nb")" ; printf ' %s\n' "${Unit2[u2_i]}" ; ((u2_i++)) ; done
)"
declare -a Units1=( ) \
           Units2=( )

while read i j k 
do
	Units1+=( "$(echo "$i $j")" )
	Units2+=( "$(echo "$j $k")" )
done < <(printf "%s\n" "$Units")

printf2 "%s\n" "${Units1[@]}"
printf2 "%s\n" "${Units2[@]}"

declare -a Ele2=(eleven twelve thirteen fourteen fifteen \
sixteen seventeen eighteen nineteen)
declare -i e2_i=0

Eles="$(\
	for i in {11..19} ; do Nb="$i" ; printf "%.0f " "$Nb" ; printf '%s' "$(espeak --ipa -q "$Nb")" ; printf ' %s\n' "${Ele2[e2_i]}" ; ((e2_i++)) ; done
)"
declare -a Eles1=( ) \
           Eles2=( )

while read i j k 
do
	Eles1+=( "$(echo "$i $j")" )
	Eles2+=( "$(echo "$j $k")" )
done < <(printf "%s\n" "$Eles")

printf2 "%s\n" "${Eles1[@]}"
printf2 "%s\n" "${Eles2[@]}"


declare Hund2="$(espeak --ipa -q 100 \
	       | sed 's/wˈɒn//g') hundred"
#	       | sed 's/wˈɒn//g') hundreds"

declare And2="ən and"

Input="$(espeak -q --ipa "$1")"

printf2 "%s\n" "$Input"

for i in ${!Eles2[@]}
do
	Input="${Input//${Eles2[i]/ */}/ ${Eles2[i]/* /}}"
done

for i in ${!Tens2[@]}
do
	Input="${Input//${Tens2[i]/ */}/ ${Tens2[i]/* /}}"
done

for i in ${!Thousands2[@]}
do
	Input="${Input//${Thousands2[i]/ */}/ ${Thousands2[i]/* /}}"
done

for i in ${!Units2[@]}
do
	Input="${Input//${Units2[i]/ */}/ ${Units2[i]/* /}}"
done

	Input="${Input//${Hund2/ */}/ ${Hund2/* /}}"

	Input="${Input//${And2/ */}/ ${And2/* /}}"

	Input="$(echo "$Input" | tr -s ' ')"

	echo "$Input" 	| sed 's/^ //' | sed 's/ty /ty-/g' \
	              	| sed 's/ and / /g' | sed 's/ty /ty-/g' \
			| sed -E 's/((one [a-z]+)s )/\2 /g'
# nb : above sed can be improved ( not ok for '^one ' regex )
# nb2 : useless if no plurals (see at top..)

	printf2 "%s" "$(echo "$1" \
			| rev \
			| sed -E 's/(...)/ \1/g' | rev)"
# nb : above can be improved
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
			break
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
	        exit 1 
		    ;;
    esac

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

