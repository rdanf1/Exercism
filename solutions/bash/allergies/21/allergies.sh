#!/usr/bin/env bash

   usage () {
	   echo "Usage : $0 <integer> allergic_to <allergy>"
	   echo "Usage : $0 <integer> list"
   } 
 
   lister () {

    local FOUND=0

    for i in $( seq 0 $((${#ALLERGIES[@]} - 1)) )
    do
	    [ "${BIN_TAB[$i]}" == "1" ] \
		    && Output[$FOUND]=${ALLERGIES[$i]} \
		    && FOUND=$(($FOUND + 1)) \
		    && EXIT=0
    done
    # If no allergy found
    # Not behavior expected for test 
    #[ "$EXIT" != "0" ] && echo "false"
    # Good for tests : If no match error exit...
    [ "$EXIT" != "0" ] && exit 4
    echo "${Output[@]}" && EXIT=0
    exit 0
   }

   main () {
   
    ALLERGIES=(cats pollen chocolate tomatoes strawberries shellfish peanuts eggs)
    for i in $(seq 0 ${#ALLERGIES[@]})
    do
	    ALLERGIES_QUERIES[$i]="allergic_to ${ALLERGIES[$i]}"
    done
    
    # Conform to test schems for parameters :
    # <integer> allergic_to <Allergy>
    # or :
    # <integer> list 
    #
    if   ( [ "a$1" == "a" ] \
    ||   ( [ a"$2" != "aallergic_to" ] && [ a"$2" != "alist"] ) \
    || ! [ -n $1 ]) 2>/dev/null
    then
	    usage ; exit 2
    fi

    #
    # The thinking part...
    #
    BIN=$(echo "obase=2;$(($1 % 255))" | bc)
    # Not available with big numbers (seq floating point notation)
    #BIN=$(seq -f "%08g" $BIN $BIN)
    # Do nothing on exercism string padding zeroes is wrong there ?!..
    #BIN=$(printf '%08s' $BIN)
    # Seems working in numerals :
    BIN=$(printf '%08d' $BIN)
    #echo "$BIN"
    BIN_TAB=($(echo $BIN | sed 's/./& /g'))

    # Check if request is successful ( even if no allergies )
    # Default value is it is not ( > 0 )
    EXIT=3

    # If 2d parameter is "list"
    [ a"$2" == "alist" ] && lister

    # After shift "$*" should be similar to 
    #       "allergic_to <iallergy>"
    shift

    for i in $( seq 0 $((${#ALLERGIES[@]} - 1)) )
    do
	    [ "${ALLERGIES_QUERIES[$i]}" == "$*" ] \
         && EXIT=0

	    [ "${ALLERGIES_QUERIES[$i]}" == "$*" ] \
	 && [ "${BIN_TAB[$i]}" == "1" ] \
	 && echo "true" && exit 0
	    
    done
    
    if [ "$EXIT" == "0" ]
    then
# Some tests were needed :
#	    echo "ARGS shifted once : $*"
#	    echo "Allergies tab : ${ALLERGIES[@]}"
#	    echo "BIN_TAB : ${BIN_TAB[@]}"
#	    echo "BIN : $BIN"

	    echo "false" && exit 0
    else
	    usage ; exit 3
    fi
	
   }

# call main with all of the positionnal arguments
   main "$@"

