#!/usr/bin/env bash
# DR - Ascen+8 - 2025
#

Source=$(cat <<FIN
- black: 0                                       - brown: 1                                       - red: 2                                         - orange: 3                                      - yellow: 4                                      - green: 5                                       - blue: 6                                        - violet: 7                                      - grey: 8                                        - white: 9
FIN
)

names=( "" $(echo "$Source" | \
                 tr -d '[:digit:]' | \
                 tr -d '[:punct:]' | \
		 tr -s '.' ' ' ) )

# Not required [ same as ind in names[ind]) ]
digits=( "" $(echo "$Source" | \
                 tr -d 'a-z' | \
                 tr -d '[:punct:]' | \
		 tr -s '.' ' ' ) )	

#echo $Source
#echo Names  : ${names[@]}
#echo Digits : ${digits[@]}
#exit

# Functions

test_params () {

	PARAMS="$*"
        #REGEX_Codes='^codes$'
        REGEX_Codes='^colors$'
	REGEX_Code='^code\ [a-z]+$'
	REGEX_Cod2='^code\ [0-9]{1}$'

	[[ ! "$PARAMS" =~ $REGEX_Codes ]] \
     &&	[[ ! "$PARAMS" =~ $REGEX_Code ]] \
     &&	[[ ! "$PARAMS" =~ $REGEX_Cod2 ]] \
     && echo Usage: "$0 [colors]/[code <color/digit>]" \
     && exit 1
#    && echo "exit 1" && exit 1

     if [[ "$PARAMS" =~ $REGEX_Code ]]
     then
         Color=$(echo "$PARAMS" | cut -d" " -f 2)
	
	 # Trailing space is required
	 #      for not being false true 
	 #      with subchain ie : "wh" / "white"
	 # if [[ "$?" -ne "0" ]]
	 if ! echo "${names[@]} " | grep -q "$Color ";
	 then
	     #echo "Color $Color KO !" 
             echo Valid Colors: "${names[@]}"
	     exit 2 
         else
	     #echo "Color $Color Ok !" 
	     :
	 fi
      else
	 # Undocumented...
	 # Last valid case Color is single digit...
         Color=$(echo "$PARAMS" | cut -d" " -f 2)
         #echo $Color
      fi
     
#     && exit 1
    
#     echo $PARAMS
}

main () {

    test_params "$@"

    if [[ "$PARAMS" =~ $REGEX_Code ]]
    then
	    # done above / test_params
	    #Color=$(echo $PARAMS | cut -d" " -f 2)
	    
	    i=0
	    while \
		    [ "${names[$((i + 1))]}" != "$2" ]
            do
		    ((i+=1))
	    done
	    echo "$i"
	    
    else
	    # Case Reverse : get color from code number...
            [[ "$PARAMS" =~ $REGEX_Cod2 ]] \
	 && echo "${names[$((Color + 1))]}" && exit 0

	    # Last valid parameter = colors 
	    for i in $( seq 1 $((${#digits[@]} - 1)) ) 
	    do
		    #echo "$((i - 1)) ${names[$i]}"
		    echo "${names[$i]}"
	    done
    fi

    exit 0 
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
#exit 99

