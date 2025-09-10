#!/usr/bin/env bash
# DR - Ascen+6 - 2025
#

# Globals

# long unsigned 2^64 - 1
#declare -r -lu Max1=18446744073709551615
# long signed +/- 2^63 - 1
#declare -r -l Max2=9223372036854775807

To_Low=""

# Functions

usage () {
	echo "Usage: $0 <pangram sentence>"
}

test_params () {

# 1 argument and only one
#        [ "$#" != "1" ] \
#     && usage \
#     &&	exit 1

No_Num=$(echo "$*" | tr -d '[:digit:]')

No_Punct=$(echo "$No_Num" | tr -d '[:punct:]')
#echo Punct $No_Punct
	
# Empty case
        [ "$No_Punct" == "" ] \
     && echo false \
     &&	exit 0

#
To_Low="$(echo "$No_Punct" | \
	  tr '[:upper:]' '[:lower:]')"
#echo Low $To_Low
#
      ! [[ "$To_Low" =~ ^[a-z].*[a-z].*$ ]] \
     && usage \
     &&	exit 1
}


main () {

 test_params "$@"

 # Straight Forward
 #ALPH1=( a b c d e f g h i j k l m \
 #	  n o p q r s t u v w x y z )

 # Spaces sed generated
 #ALPH2=( $(echo "abcdefghijklmnopqrstuvwxyz" \
 #	 | sed 's/./& /g') )

 # My best ( can choose *any* alphabet )
 #         ( here  97->122 = a-z )
 #         ( there 65-> 90 = A-Z )
 # Unicodes : 0x0000 to 0xffff caracters !
 #
 #        v Trick to get +1 blank value tab num
 ALPH3=( "" $(for j in $(for i in $(seq 97 122) ; \
	   do printf '%x\n' "$i" ; \
	   done) ; do printf "\u$j " ; done) )

# Upper's Alphabet not used.. Cf tr [:lower:]
#ALPH4=( "" $(for j in $(for i in $(seq 65 90) ; \
#	   do printf "%x\n" $i ; \
#	   done) ; do printf "\u$j " ; done) )

 # Pretty much the same :
 #echo ${ALPH1[@]}
 #echo ${ALPH2[@]}
 #echo ${ALPH3[@]}
 # Caps :
 #echo ${ALPH4[@]}

 Sentence="$To_Low"

 #
 # tab[0] == "" => skipped ok !
 #
 for i in $(seq 1 ${#ALPH3[@]})
 do
	Searched_Car=${ALPH3[$i]}

       #Searched_Maj=${ALPH4[$i]}
       #grep -qe "$Searched_Car\|$Searched_Maj" \

	echo "$Sentence" | \
        grep -qe "$Searched_Car" \
     || { echo false && exit 0 ;}
 done

 echo true
 exit 0
    
}
# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where processed above, weren't they?.) 
#
#exit 99

