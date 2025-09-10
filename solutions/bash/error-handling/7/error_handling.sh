#!/usr/bin/env bash
# DR - Ascen+4 - 2025
# NB : Not case sensitive ?!..
#
   usage () {
       echo "usage: \n
                    $0 <person>"
       exit 1  
   }

   main () {

       [ "$#" != "1" ] && usage  
       if [ "a$1" != "a" ]
       then
	   echo "Hello, $1"
       else
	      usage 
       fi
   }

#
# Call main with all of the positional arguments
#
   main "$@"
