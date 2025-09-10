#!/usr/bin/env bash
# DR - Ascen+5 - 2025
#
# The main part
# Define and choose right variables :
#

# Statics
# To avoid [0] is padded with empty value ""
A="This is the "

B=( ""
    "house that Jack built." 
    "malt" 	
    "rat" 	
    "cat" 	
    "dog" 	
    "cow with the crumpled horn" 	
    "maiden all forlorn" 	
    "man all tattered and torn" 	
    "priest all shaven and shorn" 	
    "rooster that crowed in the morn" 	
    "farmer sowing his corn" 	
    "horse and the hound and the horn" )	

C="that "

D=( ""
    ""
    "lay in" 	
    "ate" 	
    "killed" 	
    "worried" 	
    "tossed" 	
    "milked" 	
    "kissed" 	
    "married" 	
    "woke" 	
    "kept" 	
    "belonged to" )

E=" the "

# More dynamic variables
#
typeset -i Curr_Par Curr_Line Max_Par Max_Lines
Curr_Par=0
Curr_Line=0
Max_Par=$((${#B[@]} - 1))

# The maximum of lines of a paragraph
# is also its Number :
#                    Para1 : 1 line, 
#                    Para2 : 2 lines, etc...
Max_Lines=$Curr_Par
Prev_Line=""

# Functions

write_line () {

    # Trap is to use $1..

    if [[ $1 -eq 1 ]]
    then
	FirstLine=$A${B[$Max_Lines]}
        echo $FirstLine
    else
	ind_prev=$(($1 - 1))
        #if [[ $1 -eq 2 ]]
	#then
	Line="$C${D[$1]}$E${B[$ind_prev]}"
        echo $Line
	#fi
    fi
}

write_para () {

    Max_Lines=$1
    Curr_Line=1

    while ! [[ $Curr_Line -gt $Max_Lines ]]
    do
	    # Helpful for testing!
    	    #echo A Curr_Line $Curr_Line MaxL $Max_Lines
	    
	    # Tab indice !
	    li=$(($Curr_Line - 1))

	    # Only 1st Line is ok
	    # [1-Max] must be reversed...
	    Para[li]="$(write_line  $Curr_Line)"

	    #Curr_Line=+1
	    Curr_Line=$((Curr_Line + 1))
    done

    # See  the mess...
    #for i in $( seq 0 $Max_Lines)
    #do
    #echo ${Para[$i]}
    #done

    #End of Paragraph
    # First is not messed up side down...
    echo ${Para[0]}

    # Undo the mess...
    for i in $( seq 1 "$(($Max_Lines - 1))" | tac )
    do
	    echo ${Para[$i]}
    done

    # Empty line if not last paragraph
    if [[ $1 -ne $Max_Par ]]
    then
	    #echo "EndPara"
	    echo ""
    fi
    # Changed my mind : Always empty line...
    #  even if last paragraph...
    #echo "EndPara" 
    # And... changed again after taking a look at .bats...
    # echo ""
 
    # Good test stop (was very helpful!)
    #read q
}

test_params () {

        [ "$#" != "2" ] && \
	echo "2 parameters needed" \
	&& exit 1

	if [ ! -n $1 ] \
	|| [ ! -n $2 ]
        then
		#echo "2 integers needed"
		echo "invalid output"
		exit 1
	fi

        if [[ "$2" -gt "12" ]] \
        || [[ "$2" -lt "1" ]] \
        || [[ "$1" -lt "1" ]] 
        then
		#echo "Usage: $0 <verse1> <verse2> (V1<V2<12)"
		echo "invalid output"
		exit 1
	fi

        if ! [[ "$1" -le "$2" ]] 
        then
		#echo "Usage: $0 <verse1> <verse2> (Verse1 < Verse2)"
		echo "invalid output"
		exit 1
	fi
}

main () {

    #echo $A
    #echo ${B[@]}
    #echo $C
    #echo ${D[@]}
    #echo $E
 
    test_params "$@"

    for i in $(seq "$1" "$2" )	
    do
	    write_para $i
    done
 
    exit 0
}


# Call main with all of the positional arguments
   main "$@"

#
# After main call nothing is read 
#   (actually, all cases where treated above, weren't they?.) 
#
exit 99

# In this case for once,
# Appended README.md [poor memory...]
#-------------------------------------
# Workaround to keep this as "Comments"
cat <<FIN
# House

Welcome to House on Exercism's Bash Track.
If you need help running the tests or submitting your code, check out `HELP.md`.

## Instructions

Recite the nursery rhyme 'This is the House that Jack Built'.

> [The] process of placing a phrase of clause within another phrase of clause is called embedding.
> It is through the processes of recursion and embedding that we are able to take a finite number of forms (words and phrases) and construct an infinite number of expressions.
> Furthermore, embedding also allows us to construct an infinitely long structure, in theory anyway.

- [papyr.com][papyr]

The nursery rhyme reads as follows:

```text'
This is the house that Jack built.

This is the malt
that lay in the house that Jack built.

This is the rat
that ate the malt
that lay in the house that Jack built.

This is the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the man all tattered and torn
that kissed the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the priest all shaven and shorn
that married the man all tattered and torn
that kissed the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the rooster that crowed in the morn
that woke the priest all shaven and shorn
that married the man all tattered and torn
that kissed the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the farmer sowing his corn
that kept the rooster that crowed in the morn
that woke the priest all shaven and shorn
that married the man all tattered and torn
that kissed the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.

This is the horse and the hound and the horn
that belonged to the farmer sowing his corn
that kept the rooster that crowed in the morn
that woke the priest all shaven and shorn
that married the man all tattered and torn
that kissed the maiden all forlorn
that milked the cow with the crumpled horn
that tossed the dog
that worried the cat
that killed the rat
that ate the malt
that lay in the house that Jack built.
```

[papyr]: https://papyr.com/hypertextbooks/grammar/ph_noun.htm

## Source

### Created by

- @glennj

### Contributed to by

- @bkhl
- @guygastineau
- @IsaacG
- @kotp

### Based on

British nursery rhyme - https://en.wikipedia.org/wiki/This_Is_The_House_That_Jack_Built

#-------------------------------------
FIN > /dev/null
