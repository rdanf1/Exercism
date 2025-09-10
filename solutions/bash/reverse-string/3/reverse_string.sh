#!/usr/bin/env bash

   main () {
       
       if [ "a$1" != "a" ]
           then
	       #printf "%s\n" "$*" | rev
	       echo "$*" | rev
           else
	       #echo "Usage : $0 <string> [ <string> ... ]"
	       echo
	fi
   }

#   # call main with all of the positional arguments
   main "$@"
