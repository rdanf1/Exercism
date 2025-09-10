#!/usr/bin/env bash
# DR - Ascension+65 - 2025
#
# Maths : if reversing to negative then we add 26 !
#
# 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
# ----->d              k                         t->+10---
#<<<-10<d                                        t<< 19 = -7 + 26<
# Note : 
# 	  0. Oops, fixed some Opts issues..
# 	     - Values storage
# 	     - Jump to Args ( non options )
# 	  1. I will remove some comments
# 	     I swear.
#

# for 'store_Opts' 'case'
#   using +() pattern
#   for key values matching
#
shopt -s extglob

# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0


# Debugging
#    Usage: printf2 "<var descr.> :" "<var>"
# or Usage: printf2 <same as regular printf args>
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

declare -a Alpha_ar=( {a..z} )
declare -A Alpha_Aar=( )
declare -i j=0

for i in {a..z}
do
	Alpha_Aar+=( ["$i"]="$j" )
	((j++))
done

printf2 "Alpha_ar :" "${Alpha_ar[0]}"
printf2 "Alpha_Aar :" "${Alpha_Aar["a"]}"

# Functions

store_Opts () {

	#    getopt sorts input vars
	#       1. options and their values if any
	#       2. '--' ( separator = end of options )
	#       3. other arguments
	# Note : 
	#   if same option appears more than once, 
	#      last value only is kept.
	#
	#    3bis. NB0 : Optionals/Required values must be at
	#                their right position (or it's a mess !)
	#
	#       4. NB  : By definition
	#          =====================================
	#          ===  All options are optionals  =====
	#          =====================================
	#               but their values can be : 
	#        a. required ':' => next value or '' is assigned
	#                           (even if it begins with '-')
	#        b. optional '::' => next sticky value or '' !!!
	#        c. none     ''           ^ ie: -z<z_stky_val> 
	#
	# -x as extended option  (with no value!)
	# -y as eytended option  (with '' or next arg is value!)
	# -z as eztended option  (with '' or sticky is value!)  
	#     ====>  getopt -o "+xy:k:z::" -n "$0" -- "$@"      
	# -Q for disabling.. (non opt param with '-'
	#                     or useless..)
	# -o "<optchain>" => using "+<optchain>" 
	# 	=> 1st non matching value is 1st valid arg
	# 	   and all following values are args (even '-..')
	# try:
	# $0 -x -ky aa -y bb -zcIc this_is_my_1st_arg
	#{ ! TEMP0=$(getopt -o "+kxy:z::" -n "$0" -- "$@") ;} \
	#
	{ ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 'getopt error...' >&2 \
     #&& return 1
     #&& exit 1
     # ^^^^^^^^ error is non-terminate-condition
     # because sometimes we use '-' as a non-option argument

	printf2 "TEMP0 :" "$TEMP0"
        [ "$TEMP0" == "" ] && return 2

	# Note the quotes around "$TEMP": they are essential!
	#  sets getopts results in $1..$n positionnal args
	#  with 1st options and their values then '--'
	#                        then non-option args.
	eval set -- "$TEMP0"
	printf2 "TEMP0 after eval set :" "$TEMP0"
	# used in another func. (& declared in main)
	#unset TEMP0

	# Purpose is to store options
	#  not to apply them
	#
	while true
	do
	    case "$1" in

		# All couple of chars
		#           like '-'? (exept '--'!)
		# are option switchs
		#
	        #'-'[^-]) 
	   '-'[a-z] )  # adds option in associative
			#  array Opts and affects 1
			#
			opt="${1/-/}"
			Opts+=( ["$opt"]=1 )
			printf2 "!Opts :" "${!Opts[@]}"
			printf2 "Opts :" "${Opts[@]}"
			shift
			continue
			;;
		# Reached the end of options
		#  => exiting while loop
		#
	       '--' ) 	shift
			break
			;;
# kindof [:alnum:] = ko (missing a chopt ?)
#+([A-Z]|[a-z]|[0-9]) )
		# at least 1 char for key option value
 	   +([a-z]) )
		# Store previous option's value
		#  => Values are alpha lowercase
		#
			Opts["$opt"]="$1"
			printf2 "Opts :" "${Opts[@]}"
			shift
			;;
	         '' )
		# Null chain value ( it happens.. )
			printf2 "Opts Warning:" "Null Chain Value"
			printf2 "Opts is ====> -%s\n" "$opt"
			printf2 'Opts Removing %s !' "$opt" >&2
			unset "Opts[$opt]"
			shift
			;;

		# Any other values
		#   => never happens
		#      => happens if getopt error..
		#         => then 'return 1' above  
		#            => never happens !
		  * )
			printf2 'Opts Invalid value !' >&2
			printf2 'Opts Removing %s !' "$opt" >&2
			unset "Opts[$opt]"
			printf2 "!Opts :" "${!Opts[@]}"
			printf2 "Opts :" "${Opts[@]}"
		        return 2
			;;
	    esac
	done

	# Keeping positionnals
	#   After parsing options arguments
	#
	Args="$*"
}


store_Input () {

	store_Opts "$@"

	# Jump opt args (if any)
	#
	[ ! "$TEMP0" == "" ] \
     && eval set -- "$Args"

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
	#
	#  conforms with => Cf @test outputs needed
	#
REGEX_PARAM=\
'\(key\|encode\|decode\)'
REGEX_PARAMM=\
'[[:alpha:]]*'
REGEX_PARAMS=\
"^$REGEX_PARAM\( $REGEX_PARAMM\)\?$"

	# Same as above
	# for =~ comparison : no escapes
	#                     no quoted in [[..]]
REGEX_PARAM1=\
'(key|encode|decode)'
REGEX_PARA11=\
'[[:alpha:]]*'
REGEX_PARAM2=\
"^$REGEX_PARAM1( $REGEX_PARA11)?$"

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

# Tune this if needed ( called by 'test_params' )
#  ( by default displays args in debug mode )
#
check_Args () {

    # nb : if options sets '--'
    opts=0
    [ ! -v "$TEMP0" ] \
 && eval set -- "$TEMP0" && opts=1
    #
    # Shorter way to browse args :
    for arg
    do  
	if [[ "$opts" -eq 1 ]]
	then
	    if [ "$arg" == '--' ]
	    then
		opts=0
	    else
		printf2 "Opt arg :     %s\n" "$arg"
	    fi
 	else	
		printf2 "regular arg : %s\n" "$arg"
	fi
    done
}

test_params () {

	# So called
	store_Input "$@"
	test_regex "$Args"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases
  	    #
	    [[ ! "${Opts["k"]}" =~ ^[a-z]+ ]] \
	 && echo "invalid key"

echo "Usage : $0 <key|encode|decode>[ <string>]"
	    echo "Whatever says Bob"
	    return 3
	else
	#
	# From here ${Input[@]} Pattern is Ok
	#
	    #
            # Refining Regex Checks :
	    #  (regex passed !)
	    #
	    check_Args

	    if [[ "$#" -eq 1 ]]
	    then
		    [ "$1" != "key" ] \
		 && echo "error single parameter isnt \"key\"" \
		 && return 4
		    return 0
	    fi

	    if [ "${Opts["k"]}" != "" ] \
	    && [ "${Input[0]}" == "key" ]
    	    then
		    echo "error \"key\" already given (-k)"
		    return 5
	    fi

	    [ "${Input[0]}" == "key" ] \
  	 && [[ "${#Input[@]}" -ne "1" ]] \
	 && echo "error \"key\" dont need further parameter" \
	 && return 6

    if [ "${Input[0]}" != "key" ]
    then
	       [ "${Opts["k"]}" == "" ] \
	 && echo "no key given for ${Input[0]::-1}ing.." \
	 && return 7

	       [ "${Input[1]}" == "" ] \
	 && echo "no plainchain given for ${Input[0]::-1}ing.." \
	 && return 8
    fi

	    # Tolower Input
	    Input2="${Input2@L}"
	    Input[1]="${Input[1]@L}"
	    printf2 "Input2 :" "$Input2"
	    printf2 "Input[1] :" "${Input[1]}"

	    case "${Input[0]}" in

		   'key' ) return 0
			       ;;
		'encode' ) return 1
			       ;;
		'decode' ) return 2
			       ;;
	    esac


	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 254 
	fi
}

mk_key () {
	printf2 "making key.." ""
	# hidden sticky opt z 
	#    (must be hexa writen with alpha
	#     with 3 chars long max, 
	#     if not default to no opt = "" 
	#                      => "AA" = 170 (> 100)
	# nb : [0-9] isnt a valid parameter value
	#            (not in store_Opts case..)
	#
	reg_z_opt='^([a-f]|[A-F]){1,3}$'
	[[ "${#Opts["z"]}" -gt 3 ]] \
     || [[ ! "${Opts["z"]}" =~ $reg_z_opt ]] \
     && Opts["z"]=""

	_99=$((16#${Opts["z"]:="AA"}))

	for i in $(seq 1 "$_99")
	do
		key+="${Alpha_ar[SRANDOM % 25]}"
	done
	echo "$key"
}

mk_code () {

	printf2 "encoding.." ""
	printf2 "key    :" "$1"
	printf2 "string :" "$2"
	local key="$1" string="$2"
	local i key_sz="${#key}" j=0
	while [[ "${#string}" -ne 0 ]]
	do
		chr="${string:0:1}"

	    if [ "$3" == "enc" ]
	    then
		code=$((Alpha_Aar[$chr] + Alpha_Aar[${key:$j:1}]))
	    else
		code=$((Alpha_Aar[$chr] - Alpha_Aar[${key:$j:1}]))
	    fi
	    [[ "$code" -lt 0 ]] && ((code+=26))
		((code%=26))
	
		printf "%s" "${Alpha_ar[code]}"

		((j++))
		((j%=key_sz))

		string="${string:1}"
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

    # non-option args
    Args=""
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
		mk_key
		    ;;
	    1)
		mk_code "${Opts["k"]}" "${Input[1]}" enc
		    ;;
	    2)
		mk_code "${Opts["k"]}" "${Input[1]}" dec
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

