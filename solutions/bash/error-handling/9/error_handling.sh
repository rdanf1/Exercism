#!/usr/bin/env bash
# DR - Ascen+4 - 2025
# NB : Not case sensitive ?!..
#
   usage () {
       echo "Usage: $0 <person>"
       exit 1  
   }

   main () {

       # 1 single parameter
       #   otherwise usage call
       [ "$#" != "1" ] && usage  

       # Empty chain or not
       #  Same output 
       #if [ "a$1" != "a" ]
       #then
	   echo "Hello, $1"
       #else
       #   echo "Hello, $1"
       #   usage 
       $fi
   }

#
# Call main with all of the positional arguments
#
   main "$@"
