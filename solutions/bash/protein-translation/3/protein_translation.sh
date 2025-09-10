#!/usr/bin/env bash
# DR - Ascen+27 - 2025
#

Source=$(cat <<END_SRC
| Codon              | Amino Acid    |
| :----------------- | :------------ |
| AUG                | Methionine    |
| UUU, UUC           | Phenylalanine |
| UUA, UUG           | Leucine       |
| UCU, UCC, UCA, UCG | Serine        |
| UAU, UAC           | Tyrosine      |
| UGU, UGC           | Cysteine      |
| UGG                | Tryptophan    |
| UAA, UAG, UGA      | STOP          |
END_SRC
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
	#            & quotes in grep arg
	#
 REGEX_PARAMS=\
'^\(A\|G\|C\|U\)\+$'

#'^[\!-z]\+$'

	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
	#
	REGEX_PARAM2=\
'^(A|G|C|U)+$'

	# Warn
	#                    ($@  : no args)
	Input="$(printf "%s" "$*" | xargs)"

	# Uppercase
	Input=${Input@U}

	#  [ Deep regex // tests.. ]
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
            # Refining Regex Wrong cases 
  	    #
	    [ "$*" == "" ] && \
	    echo "" && exit 0
	    

	    # Whatever ( said bob.. )
	    echo "Invalid codon" 
	    exit 1
	else
	    #
            # Refining Regex Checks
  	    #
	    :

	    printf2 "Arguments Ok !"
	    return 0
	fi
}

format_Source () {

    # nb: Keep $Source unquoted !
    #     "$Source" mess it all
    #
    # Makes Source "readable" in while:
    #  ( lines with :
    #    pairs of <codons comma separated> <aacid> )
    #
    Source="$(echo $Source | tr -d ' ' \
	                   | sed  's/||/|/g' \
			   | cut -d'|' -f 6- \
			   | tr '|' ' ' \
			| sed -r 's/([a-z] )/\1\n/g')"
    
    printf2 "Source :" "$Source"
    #echo "Source : " "$Source"

    # Stores codon's transcriptions as amino-acids
    #
    while read -r codons aacid
    do
	for i in ${codons//,/ }
	do
		printf2 "codons :" "$i"
		printf2 "aacid :" "$aacid"
		Codes_Table+=( [$i]=$aacid )
	done
    done < <(echo "$Source")

    printf2 "@Codes_Table" "${Codes_Table[@]}"
    printf2 "!Codes_Table" "${!Codes_Table[@]}"
}

Transcript () {

    # All computations are done here 
    #    "au fil de l'eau" 
    # ( 3-tuples then after next 3-tuples, etc... )
    #
    # => Some Errors are raised when they happen..
    #

    # Easier for displaying results
    #
    declare -a transcript=( )

    # Some debug tests
    printf2 "Input :" "$Input"
    printf2 "Input::3 :" "${Input::3}"
    printf2 "Codes_Table[UAG]" "${Codes_Table["UAG"]}"

    # Starting iterations 
    #
    while [[ "${#Input}" -ge 3 ]]
    do
	# codon transcription from table
	codon_trans="${Codes_Table["${Input::3}"]}"
	printf2 "codon_trans :" "$codon_trans"

	# STOP found
	[ "$codon_trans" == "STOP" ] \
     && echo "${transcript[@]}" \
     && printf2 "STOP!" \
     && exit 0

	# No code found 
	[[ "${#codon_trans}" -eq 0  ]] \
     && echo "Invalid codon" \
     && printf2 "No code found!" \
     && exit 2

	# Add valid codon transcription
	transcript+=( "$codon_trans" )

	# Cut Input first 3 chars
	#                   (codon treated!)
	Input="${Input:3}"

    	# Some debug tests
	printf2 "Transcript :" "${transcript[@]}"
	printf2 "Input :" "$Input"	
    done
    [[ "${#Input}" -eq 0 ]] \
 && echo "${transcript[@]}" \
 && exit 0

    echo "Invalid codon"
    printf2 "Not 3-tuple : Incomplete sequence.."
    exit 3
}

main () {

    # Associative array to store 
    #   codons and their amino-acid transcriptions
    #
    declare -A Codes_Table=( )

    declare Input=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		format_Source
		Transcript
		    ;;
	    *)
		printf2 "An Invalid Input Occurred"
	        exit 1 
		    ;;
    esac

# Unreached mostly..
#   exit 0
}


# Call main with all of the positional arguments
   main "$@"

