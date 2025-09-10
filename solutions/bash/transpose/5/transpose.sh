#!/usr/bin/env bash
# DR - Ascension+68 2025 - no comments -188 lines
# 				       ~144 without "^$"
shopt -s extglob

# Debug mode printf
DEBUG=0

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
	return 0
}

# Purpose : store options (if any)
store_Opts () {
	{ ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 "%s" 'getopt error...' >&2 \

	printf2 "TEMP0 :" "$TEMP0"
        [ "$TEMP0" == "" ] && return 2
	#        to un-quote ?
	eval set -- "$TEMP0"
	printf2 "TEMP0 after eval set :" "$TEMP0"

	while true
	do
	    case "$1" in

	    '-'[a-z])   opt="${1/-/}"
			Opts+=( ["$opt"]=1 )
			printf2 "!Opts :" "${!Opts[@]}"
			printf2 "Opts :" "${Opts[@]}"
			shift
			continue
			;;
	       '--' ) 	shift
			break
			;;
 	   +([a-z]) )
			Opts["$opt"]="$1"
			printf2 "Opts :" "${Opts[@]}"
			shift
			;;
	         '' )
			printf2 "Opts Warning:" "Null Chain Value"
			printf2 "Opts is ====> -%s\n" "$opt"
			shift
			;;
		  * )
			printf2 "%s" 'Opts Invalid value !' >&2
			printf2 'Opts Removing %s !' "$opt" >&2
			unset "Opts[$opt]"
			printf2 "!Opts :" "${!Opts[@]}"
			printf2 "Opts :" "${Opts[@]}"
		        return 2
			;;
	    esac
	done
	Args="$*"
}

# Store regular arguments ( not options)
#
#  => some changes here because of '<<< "input"'
#          ( novelty used in @test bats file.. )
#
store_Input () {
	# reading from '<<< "Ansi-C string"
	IFS=$'\n'
	read -d'\n' Args

	# Restitution to standard positionnal arguments
	eval set -- $Args
	printf2 "Args : ==%s==" "$Args"

	# Opts losts initials $'\n'
	# once stripped options with getopt
	#   => commented.. 
	#store_Opts "$@"

	i=0
	while read -r Input["i"]
	do
		((i++))
	done < <(echo "$Args")
	
	printf2 "unset of Input[%i] %s" "$i" "${Input[i]}"
	# Last value is an empty line  => to remove !
	unset "Input[i]"

	# Debuging check
	for i in "${!Input[@]}"
	do
		Input[i]="${Input[i]// /_}"
		printf2 "Input[%i] : %s" "$i" "${Input[i]}"
	done
	# "Flat" input for passing regex
	Input2="Unused"
	# to avoid "unreachable" but unused
	store_Opts "$@"
}

test_regex () {

# Pretty much everything
#        "print"able goes through..
REGEX_PARAM=\
''
REGEX_PARAMM=\
'[[:print:]]*'
REGEX_PARAMS=\
"^$REGEX_PARAM$REGEX_PARAMM$"

REGEX_PARAM1=\
''
REGEX_PARA11=\
'[[:print:]]*'
REGEX_PARAM2=\
"^$REGEX_PARAM1$REGEX_PARA11$"

	printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}

# Ckeck / List *All* arguments
check_Args () {

    opts=0
    [ ! -v "$TEMP0" ] \
 && eval set -- "$TEMP0" && opts=1
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

	store_Input "" #: no-no parameters (Cf read)
	test_regex "$Args"

	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
echo "Usage : $0 <<< $'Ansi-C string'"
	    return 1
	else
	    check_Args

	    printf2 "Arguments Ok !"
	    return 0
	fi
}

# Specifics funcs. for Pb
#
max_Size () {
	for i in "${!Input[@]}"
	do
		[[ "$max_size" -lt "${#Input[$i]}" ]] \
	     && max_size="${#Input[$i]}"
	done
	echo "$max_size"
}

mk_Transpose () {
	maxsize="$(max_Size)"
	while [[ "$maxsize" -ne 0 ]]
	do
	    for i in "${!Input[@]}"
	    do
		chr="${Input[$i]:0:1}"

		if [[ "$i" -eq "$((${#Input[@]} - 1))" ]]
		then     # Last column
		         # not filling
		    [ "$chr" == "" ] && break
		    result+="$(printf "%s" "${chr}")"
		else     # not last
			 # filling with ' '
		    result+="$(printf "%s" "${chr:= }")"
		fi
		Input[i]="${Input[i]:1}"
	    done
	((maxsize--))
	printf "%s\n" "$result" | sed 's/[ ]*$//' \
				| sed 's/_/ /g'
	result=""
	done
}

main () {
    declare TEMP0=""
    declare -A Opts=( )
    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
	    0)	mk_Transpose
		    ;;
	    *)  printf2 "An Invalid Input Occurred"
	        exit 1
		    ;;
    esac
    exit 0
}

main "$@"

