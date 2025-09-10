#!/usr/bin/env bash

   usage () {
	   echo "Usage : $0 <integer> allergic_to <allergy>"
   } 

   main () {
   
    ALLERGIES=(cats pollen chocolate tomatoes strawberries shellfish peanuts eggs)
    for i in $(seq 0 ${#ALLERGIES[@]})
    do
	    ALLERGIES_QUERIES[$i]="allergic_to ${ALLERGIES[$i]}"
    done
    
    # Conform to test schems for parameters
    # <integer> allergic_to <Allergy>
    #
    if  ([ "a$1" == "a" ] \
    || ! [ a"$2" == "aallergic_to" ] \
    ||   [ a"$3" == "a" ] \
    || ! [ -n $1 ]) 2>/dev/null
    then
	    usage ; exit 2
    fi


    # The thinking part...
    BIN=$(echo "obase=2;$(($1 % 255))" | bc)
    # Do nothing on exercism...
    BIN=$(printf '%08d' $BIN)
    #BIN=$(seq -f "%08i" $BIN $BIN)
    echo "$BIN"
    BIN_TAB=($(echo $BIN | sed 's/./& /g'))
    # Identify allergy is asked for (2d parameter)

    EXIT=3
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
	    echo "ARGS shifted once : $*"
	    echo "Allergies tab : ${ALLERGIES[@]}"
	    echo "BIN_TAB : ${BIN_TAB[@]}"
	    echo "BIN : $BIN"

	    echo "false" && exit 0
    else
	    usage ; exit 3
    fi
	
   }

# call main with all of the positionnal arguments
   main "$@"

