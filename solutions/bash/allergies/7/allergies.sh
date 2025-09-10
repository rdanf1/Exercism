#!/usr/bin/env bash

   usage () {
	   #echo "Usage : $0 <integer> allergic_to_<allergy>"
	   echo "false"
   } 

   main () {
   
    ALLERGIES=(cats pollen chocolate tomatoes strawberries shellfish peanuts eggs)
    for i in $(seq 0 ${#ALLERGIES[@]})
    do
	    ALLERGIES_QUERIES[$i]="allergic_to_${ALLERGIES[$i]}"
    done
    
    # Conform to test schems for parameters
    # <integer> allergic_to_<Allergy>
    #
    if ([ "a$1" == "a" ] \
    || [ a"$2" == "a" ] \
    || ! [ -n $1 ]) 2>/dev/null
    then
	    usage ; exit 2
    fi


    # The thinking part...
    BIN="$(echo "obase=2;$(($1 % 255))" | bc)"
    BIN=$(printf "%08s\n" $BIN)
    BIN_TAB=($(echo $BIN | sed 's/./& /g'))

    # Identify allergy is asked for (2d parameter)

    for i in $( seq 0 $((${#ALLERGIES[@]} - 1)) )
    do
	    [ "${ALLERGIES_QUERIES[$i]}" == "$2" ] \
	 && [ "${BIN_TAB[$i]}" == "1" ] \
	 && echo "true" && exit 0
	 
    done

    echo "false" && exit 1
	
   }

# call main with all of the positionnal arguments
   main "$@"

