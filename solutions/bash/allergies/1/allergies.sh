#!/usr/bin/env bash

   main () {
   
    ALLERGIES=(cats pollen chocolate tomatoes strawberries shellfish peanuts eggs)

    # first param not null and numeric value
    if ([ "a$1" != "a" ] \
    && [ a"$2" == "a" ] \
    && [ -n $1 ]) 2>/dev/null
#    && [ "$1" -eq "$1" ]) 2>/dev/null
    then
	   if [ $1 -eq 0 ]
	   then
		echo "Allergy NOT found !"
		exit 0
	   fi

           #printf "%s\n" "$*" | rev
	   BIN="$(echo "obase=2;$(($1 % 255))" | bc)"
	   BIN=$(printf "%08s\n" $BIN)
	   BIN_TAB=($(echo $BIN | sed 's/./& /g'))
	   #echo $BIN
	   #echo $BIN_TAB
	   #echo ${BIN_TAB[@]}
	   #echo ${#BIN_TAB[@]}
	   j=0
	   for i in "${BIN_TAB[@]}"
           do
	      if [ $i == 1 ]
              then
		echo "Allergy found : ${ALLERGIES[$j]}"
	      fi
	      j=$(($j + 1))
	   done
    else
	   echo "Usage : $0 <integer>"
	   #echo
    fi

   }

#   # call main with all of the positional arguments
   main "$@"







