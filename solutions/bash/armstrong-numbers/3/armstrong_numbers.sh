#!/usr/bin/env bash

   default () {
	       echo "Usage : $0 <number>"

   }

   main () {
       
       if ([ "a$1" != "a" ] \
	&& [ -n "$1" ])
       then
	       ARM_NB=0
	       SPLITED=($(echo "$1" | sed 's/./& /g'))
	       #POWER=$(printf "$1" | wc -m)
               POWER=${#SPLITED[@]}
	       #echo POWER $POWER
	       for i in $( seq 0 $(($POWER - 1)) ) 
	       do
		       #echo "i : $i"
		       (( ARM_NB+=$((${SPLITED[$i]} ** $POWER)) ))
		       #echo ARM_NB $ARM_NB
	       done
	       
	       [ "$1" == "$ARM_NB" ] && echo "true" && exit 0
               
	       echo "false" && exit 0
       else
	       default
	       exit 1
       fi
   }

#   # call main with all of the positional arguments
   main "$@"
