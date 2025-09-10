#!/usr/bin/env bash

   usage () {
       echo "Usage : $0 \"<Name>\""
       exit 1  
   }

   main () {

       [ "$#" != "1" ] && usage  
       if [ "a$1" != "a" ]
       then
	   echo "Hello $1!"
       else
	      usage 
       fi
   }

#
# Call main with all of the positional arguments
#
   main "$@"
