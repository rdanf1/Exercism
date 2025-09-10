#!/usr/bin/env bash

   main () {
       
       if [ "a$1" != "a" ]
           then
	       #printf "%s\n" "$*" | rev
	       echo "One for $*, one for me."
           else
	       #echo "Usage : $0 <string> [ <string> ... ]"
	       echo "One for you, one for me."
	fi
   }

#   # call main with all of the positional arguments
   main "$@"
