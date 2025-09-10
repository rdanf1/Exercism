#!/usr/bin/env bash

   default () {
	       echo "Usage: $0 <string1> <string2>"
	       exit "$1"
   }

   split_str () {
	   echo "$1" | sed 's/./& /g'
   }

   size_str () {
	   split_str "$1" | wc -w
   }
 
   main () {

       [ "$#" != "2" ] && default 1
       [ "$(echo "$1a$2" | grep ' ')" != "" ] && default 2

          [ "a$1" == "a" ] \
       && [ "a$2" == "a" ] && echo 0 && exit 0 
       
        ! [ $(size_str "$1") == $(size_str "$2") ] \
       && echo 'strands must be of equal length' && exit 3

       # Exited above...
       #if [ "a$1" != "a" ] \
       #&& [ "a$2" != "a" ] \

       # Well formed strands (with these 4 letters) 
       if [[ "$1" =~ (C|A|G|T)? ]] \
       && [[ "$2" =~ (C|A|G|T)? ]]
           then
		# Integer type declaration
		# for the use of =+ operator 
		#    ( not concatenation that is default behaviour ) 
		typeset -i HAM
		HAM=0

	   	TAB_CHAIN1=( $(split_str "$1") ) 
	   	TAB_CHAIN2=( $(split_str "$2") ) 

		# Some tests	
		#echo Chain1 ${TAB_CHAIN1[@]}
		#echo Chain2 ${TAB_CHAIN2[@]}

		for i in $(seq 0 $((${#TAB_CHAIN1[@]} - 1)))
		do
		    [ "${TAB_CHAIN1[$i]}" != "${TAB_CHAIN2[$i]}" ] \
			    && HAM+=1
			     # HAM is an integer ( declared above )
		done
           else
	      # Is error function ( with exit error code )
	      default 4
	fi
	echo $HAM
   }

# Call main with all of the positional arguments
   main "$@"

