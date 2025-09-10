#!/usr/bin/env bash

   main () {
       if [ "a$1" != "a" ]
           then
               shift
	       echo $* | rev
           else
	       echo "Usage : $0 <string> [ <string> ... ]"
	       exit 1
	fi
   }

#   # call main with all of the positional arguments
   main "$@"
