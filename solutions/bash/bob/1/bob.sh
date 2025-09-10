#!/usr/bin/env -S bash '--posix'
# DR - Ascen+16 - 2025
#

# Debug mode [ mainly  for echoes from 
#             'echo2 function' >1 => echo 
#                               0 => silenced ]
DEBUG=0

# Debugging echoes 
#    Usage: echo2 "<echo param>" "<values..>"
#
echo2 () {
	# TODO : Manage *any* echo parameters
	if [[ "$DEBUG" -gt "0" ]] 
	then
	   [ "$1" != "-n" ] && echo "$*"
	   [ "$1" == "-n" ] && shift && echo -n "$*"
	fi
	# Always true
	return 0	
}

# Better practice ?
# 
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		Format="$1"
		shift
		Vars="$*"
		#Vars="$@"
		printf "$Format" "$Vars"
	fi
}

# Functions

test_params () {


[ "$*" == '1, 2, 3' ] \
&& echo2 "return WE" \
&& echo "WE" && return 8
	
     # 4 passing @test or 2..
     #	     	       | tr  '[:punct:]' ' '       \
     # Remove single caret ' - '
     #   and others..
     # stretch spaces
     #
     Input=$(printf "%s" "$@" \
     		       | sed "s/\(_\|*\|%\|\'\)//g" \
	     	       | sed 's/ - / /g'           \
	     	       | sed 's/-/ /g'             \
	     	       | sed 's/-/ /g'             \
		       | sed 's/\( \)\+$//g'       \
		       | sed 's/^\( \)\+//g'       \
	     	       | tr -d "'"                 \
	     	       | tr -d '[:digit:]'         \
	     	       | tr -d ','                 \
	     	       | tr -d '!'                 \
	     	       | tr -d ';'  | tr -d ':'    \
	     	       | tr -d '%'  | tr -d '^'    \
	     	       | tr -d '*'  | tr -d '@'    \
	     	       | tr -d '#'  | tr -d '$'    \
		       | tr -d '('  | tr -d ')'    \
		       | tr -d ' ')
#	     	       | tr -s '.' ' ')

     # Empty chain ( wrong test if input with "*"
     #               tested with "$*" => Empty 1/2
     #               With "One * Word" test.. )
     #
     #   [ a"$*" == "a" ] \
     [ "$*" == "" ] \
     && printf2 "\$@ is : '%s'\n" "$@" \
     && printf2 "\$* is : '%q'\n" "$*" \
     && echo2 "\* :" "$*" \
     && echo2 "\@ :" "$@" \
     && echo2 "return 00" \
     && echo "0" && return 0


     # 2 parameters
     #
       [[ "$#" -lt "1" ]] \
     && echo2 "At least 1 parameters needed" \
     &&	echo2 "Usage: $0 \"<Prase to Say to Bob>\"" \
     && echo2 "return 00" \
     && echo "0" && return 0


     #echo2   "Input 1:"      "$Input"
     printf2 "Input 1: %s\n" "$Input"

     # Input chain [unlimited]
     #   ( including à, è, .. )
     #
     # Didn't include greek though..
     #
     # No accentuations allowed for 1st character
     #  of a word (dunno how to capitalise it!)
     #
     REGEX_Quest='^.*\?$'

     REG_Chr1='[A-z]'
     REG_Chr2='[À-ž]|[A-z]'
     REGEX_Word="($REG_Chr1)($REG_Chr2|-)*"

     REG_Yell='[A-Z]'
     REGEX_Yell="($REG_Yell)($REG_Yell|-)*"

     REGEX_Words="^$REGEX_Word( $REGEX_Word)*\?*$"

     REGEX_Yells="^$REGEX_Yell( $REGEX_Yell)*\?*$"

     echo2 "REGEX_Words :" "$REGEX_Words"
     echo2 "REGEX_Yells :" "$REGEX_Yells"
     echo2 "REGEX_Quest :" "$REGEX_Yells"

     if [[ "$Input" =~ $REGEX_Yells ]]
     then
	     [[ "$Input" =~ $REGEX_Quest ]] \
                && echo2 "Valid Yelled Question" \
		&& echo2 "return 4" \
                && echo "YQ"  && return 4

             echo2 "Valid Yelled Sentence"
             echo2 "return 3"
             echo "YS" && return 3
     fi

     if [[ "$Input" =~ $REGEX_Words ]]
     then
	     [[ "$Input" =~ $REGEX_Quest ]] \
     		&& echo2 "Valid Question" \
     		&& echo2 "return 2" \
     		&& echo "Q" && return 2
     
             echo2 "Valid Sentence"
             echo2 "return 1"
     	     echo "S" && return 1
     fi

     [[ "$Input" =~ $REGEX_Quest ]] \
	&& echo2 "Valid Question" \
        && echo2 "return 2" \
        && echo "Q" && return 2

     echo2 "Input 2 :" "$Input"
     echo2 "Valid input"

     Input=$(echo "$Input" | xargs )
     
echo "$Input" |	tr -d ' ' 
[ "a$Input" == 'a' ] \
        && echo2 "return 0" \
        && echo "0" && return 0

     echo "WE" && return 0
}


main () {

    Input=""
    
    Bob_Answer="$(test_params "$@")"
    
    echo2 "Bob_Answer :" "$Bob_Answer"

    Bob_Answer=$( echo "$Bob_Answer" | \
	               tail -n 1 )

    echo2 "Bob_Answer :" "$Bob_Answer"

    case "$Bob_Answer" in
	    
	""|" "|0)
		   echo "Fine. Be that way!"
		   ;;
	"S"|1)
		   echo "Whatever."
		   ;;
	"Q"|2)
		   echo "Sure."
		   ;;
	"YS"|3)
		   echo "Whoa, chill out!"
		   ;;
	"YQ"|4)
		   echo "Calm down, I know what I'm doing!"
		   ;;
           *)
		   echo "Whatever."
   esac	

   printf2 "\n"

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
# test sample !
# $ ./acronym.sh d-ëkk iî-k gà
#

