#!/usr/bin/env bash

   default () {
	       echo "One for you, one for me."

   }

   main () {
       
       if [ "a$1" != "a" ]
           then
		   echo "One for "$1", one for me."
           else
	      default 
	fi
   }

#   # call main with all of the positional arguments
   main "$@"
