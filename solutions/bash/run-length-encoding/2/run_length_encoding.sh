#!/usr/bin/env bash
# DR - Ascension+63 - 2025
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

	# Note the quotes around "$TEMP0": they are essential!
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
REGEX_PARAMM=\
'[A-Z]*'
REGEX_PARAMS=\
"^$REGEX_PARAMM$"

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM1=\
'(encode |decode )?'
REGEX_PARA11=\
'([A-z]| |[1-9])*'
REGEX_PARAM2=\
"^$REGEX_PARAM1$REGEX_PARA11$"

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

echo "Usage : $0 <encode|decode> <alpha string>"
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

	    [[ "$1" == "decode" ]] && return 254 

	    return 0
	fi
}

mk_encode () {

	local Input1="$1" 
	local -i count=1

	while [[ "${#Input1}" -ne 0 ]]
	do
	    while [ "${Input1:0:1}" == "${Input1:1:1}" ]
	    do 
		    ((count++))
		    Input1="${Input1:1}"
	    done

	    if [[ "$count" -gt 1 ]]
	    then
		    printf "%i%s" "$count" "${Input1:0:1}"
		    count=1
            else
		    printf "%s" "${Input1:0:1}"
	    fi

	    Input1="${Input1:1}"
    	done
	printf '\n'
}

mk_decode () {

	local Input1="$1" count_digits=""
	local -i count=1


	while [[ "${#Input1}" -ne 0 ]]
	do
	    while [[ "${Input1:0:1}" =~ ^[1-9]$ ]]
	    do 
		 count_digits+="${Input1:0:1}"
	    	 Input1="${Input1:1}"
	    done
	    [[ ${#count_digits} -ne 0 ]] \
         && count=$((count_digits))

	    while [[ "$count" -gt 0 ]]
	    do 
		  ((count--))
		  printf "%s" "${Input1:0:1}"
	    done

	    Input1="${Input1:1}"
	    count=1
	    count_digits=""
    	done

	printf '\n'
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
		mk_encode "${Input[1]}"
		    ;;
	  254)
		mk_decode "${Input[1]}"
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

