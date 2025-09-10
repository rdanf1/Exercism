#!/usr/bin/env bash
# DR - Ascension+63 - 2025
#
# Maths
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
REGEX_PARA0=\
'-\?'
REGEX_PARA1=\
'\( \(A\|R\|L\)\+\)\?'
REGEX_PARAM=\
'\(north\|east\|south\|west\)'
REGEX_PARAMM=\
'[0-9]\+[0-9]*'
REGEX_PARAMS=\
"^$REGEX_PARA0$REGEX_PARAMM $REGEX_PARA0$REGEX_PARAMM \
$REGEX_PARAM$REGEX_PARA1$"

#"^$REGEX_PARA0$REGEX_PARAMM $REGEX_PARA0$REGEX_PARAMM \
#$REGEX_PARAM$REGEX_PARA1$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM0=\
'\-?'
REGEX_PARAM1=\
'(north|east|south|west)'
REGEX_PARA11=\
'[0-9]+[0-9]*'
REGEX_PARAM2=\
"^$REGEX_PARAM0$REGEX_PARA11 $REGEX_PARAM0$REGEX_PARA11 \
$REGEX_PARAM1( (A|R|L)+)?$"

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
	# Cf @test ?!
	[[ "$#" -eq 0 ]] && echo "0 0 north" && exit 0

	REGEX_VALID_DIR='(north|east|south|west)'
	if [[ ! "$Input2" =~ $REGEX_VALID_DIR ]]
	then
		echo "invalid direction"
		exit 2
	fi
	
	if [[ "${#Input[3]}" -ne 0 ]]
	then
	    if echo "${Input[3]}" | grep -q "[^ARL]"
	    then
		echo "invalid instruction"
		exit 3
	    fi
	fi

echo "Usage : $0 <x> <y> <orientaº>[ <instrucº>]"
echo "x, y ∈ ℕ, orientation ∈ { north, south, east, west }"
echo "         instructions ∈ { A, R, L }"
echo "     A : Advance, R / L : rotate Right / Left"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here Input is "regex correct" 
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

	    # from '--' to <1st arg>
	    shift     
	fi
	    # Jump after <1st arg> 
	    #shift     # from <1st arg> to <2d arg>

	    # Here remaining args after options
	    #
	    # Shorter way to browse 
	    #          positionals args :
	    for arg
	    do
	     	  printf2 "arg :" "$arg"
	    done
	    
	    # If specific args values to check
	    #  use of 'case' :	 
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

add_coords () {

	local X_Y="$1" x_y="$2"

	X="${X_Y/ */}"
	Y="${X_Y/* /}"

	#printf2 "X_Y :" "$X_Y"; 
	#printf2 "X :" "$X" ; printf2 "Y :" "$Y"

	x="${x_y/ */}"
	y="${x_y/* /}"

	#printf2 "x_y :" "$x_y"
	#printf2 "x :" "$x" ; printf2 "y :" "$y"

	echo "$(( X + x )) $(( Y + y ))"
}
# Some tests of above func.
#add_coords "1 2" "3 4"
#add_coords "-1 -2" "-3 -4"

mk_move () {

	local -a directions=( "north" "east" "south" "west" )

	local -A advances=( ["north"]="0 1" ["east"]="1 0" \
		            ["south"]="0 -1" ["west"]="-1 0" )

	local -i direct_ind=-2

	coord="${Input[0]} ${Input[1]}"
	direct="${Input[2]}"
	printf2 "direct :" "$direct"

	for i in {0..3}
	do 
		if [ "$direct" == "${directions[i]}" ]
		then
			direct_ind="$i"
			break
		fi
	done
	printf2 "direct_ind 1:" "$direct_ind"

	while [[ "${#Input[3]}" -ne 0 ]]
	do
		case "${Input[3]:0:1}" in

		    'R') printf2 "at :" "R"
			((direct_ind++))
			if [[ "$direct_ind" -gt 3 ]]
			then
				direct_ind="0"
			fi
			direct="${directions[direct_ind]}"
				;;
		    'L') printf2 "at :" "L"
			((direct_ind--))
			if [[ "$direct_ind" -lt 0 ]]
			then
				direct_ind="3"
			fi
			direct="${directions[direct_ind]}"
				;;
		    'A') printf2 "at :" "A"
	# Need '$direct' with associative array..
	printf2 "advances[direct] :" "${advances[$direct]}"
	coord="$(add_coords "$coord" "${advances[$direct]}")"
				;;
		      *) echo "never happens.."
				;;
		esac
		printf2 "direct_ind N:" "$direct_ind"

		# Read next char in instructions set
		Input[3]="${Input[3]:1}"
	done

	printf2 "direct_ind last:" "$direct_ind"
	printf2 "directions[direct_ind] :" \
	        "${directions[direct_ind]}"

	echo "$coord $direct"
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
		mk_move "${Input[@]}"
		    ;;
	    *)
		printf2 "An Invalid Input Occurred"
	        exit 1 
		    ;;
    esac

    exit 0
}

# Call main with all of the positional arguments
   main "$@"

