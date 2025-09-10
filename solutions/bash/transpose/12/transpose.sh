#!/usr/bin/env bash
# DR - Ascension+68 2025 - no comments -188 lines = base !
# 	186-226 = 40 lines	-      -144 without "^$"
# Note : "printf2/DEBUG" lines should be removed too !!
# NB: Go & See before this very un-commented exercism
#     for further comments about the 144 (they might be outdated!)
#
# Opts : Are managed (stored) then cutted from Args !
# todo : 0. Avoid 's/ /_/' "trick" 
#        1. Forbidden input chars => Enable them.
#
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
# nb: here all options are undocumented ( and with 0 effects! )
#     try $'-x -y ee -zstk Ansi-C\nstring to\ntranspose'
store_Opts () {            #  '+:' means optº comes as 1sts args!
	{ ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 "%s" 'getopt error...' >&2

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
			Args="${Args/ $1 /}"  # 1st opt (or..)
			Args="${Args/$1 /}"   # nth opt (or..)
	    		Args="${Args/$1/}"    # sticky opt
			shift
			continue
			;;

	    '--' ) 	shift
			break
			;;

 	    +([a-z]) )  Opts["$opt"]="$1"
	    		Args="${Args/$1 /}"
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
			Args="-$opt $Args"
			unset "Opts[$opt]"
			printf2 "!Opts :" "${!Opts[@]}"
			printf2 "Opts :" "${Opts[@]}"
		        return 2
			;;
	    esac
	done
}

# Store arguments ( options + regular )
#
#  => some changes here because of '<<< "input"'
#          ( novelty used in @test bats file.. )
#
##############################################################
# Sample for testing inputs : comment li.109 (and 108's '\') #
##############################################################
# for i in {2..9}{0..9} {2..9}{a..f} {a..f}{0..9} {a..f}{a..f} ; do ./transpose.sh <<< $(printf %b "-x -y yy -zstk Ansi-C\nstring to\ntranspose\n\x$i") ; printf %b "\x$i" ; read q ; done p
# ############################################################
store_Input () {
	# reading from '<<< "Ansi-C string"
	read -r -d'\n' Args
	# ",',&,(,),`,|             : $'\x3c', $'\x3e'
	# Those above chars are no allowed '&' is unstoppable..
	#  .. though stopped here :
	echo $Args | grep -q '&\|_' \
     && echo "invalid input (&/_)"  \
     && exit 11

	# Restitution to standard positionnal arguments
	# nb: no quotes here (lost lines..) ! 
	# (if an error occurs then at least 1 input chr is wrong!)
	eval set -- $Args 2>/dev/null \
     || { echo "invalid input" && exit 1 ;}
	printf2 "Args : ==%s==" "$Args"

	# Opts losts initials input lines
	#  once stripped with 'getopt'
	#   => Truncating above '$Args' directly = Ok
	store_Opts "$@"

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
		# A shortcut to issues with mixed contents
		#  => replacing *real* spaces with '_'
		Input[i]="${Input[i]// /_}"
		printf2 "Input[%i] : %s" "$i" "${Input[i]}"
	done
	# "Flat" input for passing regex
	Input2="Unused"
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
	Line=""
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
		    Line+="$(printf "%s" "${chr}")"
		else     # not last
			 # filling with ' '
		    Line+="$(printf "%s" "${chr:= }")"
		fi
		Input[i]="${Input[i]:1}"
	    done
	((maxsize--))
	# 0. trailing padding spaces are removed
	# 1. *real* columns spaces are '_' 
	#    => restituted as spaces (Cf shortcut..)
	#
	printf "%s\n" "$Line"   | sed 's/[ ]*$//' \
				| sed 's/_/ /g'
	Line=""
	done
}

main () {
    IFS=$'\n'
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
