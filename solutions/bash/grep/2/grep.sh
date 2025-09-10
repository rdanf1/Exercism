#!/usr/bin/env bash
# DR - Ascension+43 - 2025
#
# Analyse
#
# 	Time to modify "store_Input"
# 	        adding options management..
#
# NB: Todo : Modify 'if' "escaladations" (78 lines!)
#                    in  'mk_grep_files' !!! (~140 lines!)
#                       ( func. to split )
#
# NB2: Took longer than expected (as usual..)
# NB3: This code is *totally* dumb..
#      though all @tests passed!
#


# Debug mode [ mainly  for echoes from
#              'printf2 function' >1 => echo
#                                  0 => silenced ]
DEBUG=0

# Debugging
#    Usage: printf2 "<var descr.> :" "<var>"
#
printf2 () {
	if [[ "$DEBUG" -gt "0" ]]
	then
		printf '%s\n' "$*"
	fi
	# Always true
	return 0
}


# Functions

store_Input () {

	# Manage options
	#    getopt sorts input vars
	#       1. options and their values if any
	#       2. '--' ( separator = end of options )
	#       3. other arguments
	#
	#[ $? -ne 0 ] \
	{ ! TEMP0=$(getopt -o 'nlivx' -n "$0" -- "$@") ;} \
     && echo 'Terminating...' >&2 \
     && exit 1

	printf2 "TEMP0 :" "$TEMP0"

	# Note the quotes around "$TEMP": they are essential!
	eval set -- "$TEMP0"
	unset TEMP0


	# Purpose is to store options
	#  not to apply them
	#
	while true
	do
	    case "$1" in

		# All chars like '-'* (exept '--'!)
		# are option switchs
		#
		# If any values for options
		#  => to treat after shift
		#
		'-'[^-]) # adds opt in associative
			#  array Opts and affects 1
			#  (if any value affects
			#      value after shift!)
			#
			Opts+=( [${1/-/}]=1 )
			printf2 "!Opts :" "${!Opts[@]}"
			shift
			continue
			;;
		# Reached the end of options
		#  => exiting while loop
		#
		'--') 	shift
			break
			;;
		# Any other values
		#   => never happens
		#
		*) 	echo 'Internal error!' >&2
			exit 2
			;;
	    esac
	done


	# Remaining arguments
	#    (this part is unchanged!)
	#
	#     <=> $arg1 $arg2 .. $argn
	#

	while [[ "$#" -gt 0 ]]
	do
	    Input+=( "$1" )
	    Input2+=" $1"
	    printf2 "Input while :" "${Input[@]}"
	    shift
	done
	    Input2="${Input2:1}"
	    printf2 "Input2 :" "$Input2"
}

# Figure out input shape as
#                required/correct
test_regex () {

        # for grep :   escapes 
	#            & quotes in grep arg
	# at least 1 or more words needed
	#
	#  conforms with
    	#   "Usage : $0 <opts..> <string> <files..>"
	#
REGEX_PARAMS=\
'^[ -~]*$'

	# Same as above
	# for =~ comparison : no escapes 
	#                     no quoted in [[..]]
REGEX_PARAM2=\
'^[ -~]*$'

	#  [ Deep regex // tests.. ]
	#
	printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
     || printf2 'RegExpr Wrong as usual ! (grep)'

	[[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}


test_params () {

	# So called
	store_Input "$@"

	test_regex "$@"

	# Checking what's Wrong 1st
	#              for sure.
	#
	if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
	then
	    printf2 "Imput Wrong Regex"
            # Refining Regex Wrong cases 
  	    #

	    # Whatever ( said bob.. )
    	    echo "Usage : $0 <opts..> <string> <files..>"
	    echo "Whatever says Bob"
	    return 1
	else
	#
	# From here ${Input[0]} is 1 [A-Z] letter
	#
	    #
            # Refining Regex Checks : 
	    #  (regex passed !)
	    #
	    
	# Args Ok
	#
	    printf2 "Arguments Ok !"
	    return 0
	fi
}

mk_grep_files () {

    Pattern="$1"
    shift
    
    file2="$#"

    for file;
    do
    	declare -a result=( )

    	local -i positive=0 line_no=1

	# for append "$line_no:" once!
	#
	strt=0

	# check for -l once!
	# th3re is already file
	#
	files=0

	while read -r line
	do
	    # If matching succeed = 1
	    #
	    positive=0	

	    # Almost forgotten.. 
	    #   (keeping original line for output)
	    line0=""
	    [[ ${Opts["i"]} -eq 1 ]] \
	 && line0="$line" \
	 && line=${line@L} && Pattern="${Pattern@L}"

	    #printf2 "line :" "$line"
	    #printf2 "Pattern :" "$Pattern"

	    # This *is* dumb !
	    #
	    if [[ ${Opts["x"]} -eq 1 ]]
	    then
	      if [[ ${Opts["v"]} -eq 1 ]]
	      then
	        if [[ ! "$line" == "$Pattern" ]]
	        then
		  positive=1
	      	  if [[ ${Opts["l"]} -eq 1 ]]
	          then
		      [[ "$files" -eq 0 ]] && \
		      result+=( "$file" )

		      ((files++))
		      break
		  else
		      result+=( "${line0:="$line"}" )
		  fi
		fi
	      else
		# Not -v
	        if [[ "$line" == "$Pattern" ]]
	        then
		  positive=1
	      	  if [[ ${Opts["l"]} -eq 1 ]]
	          then
		      [[ "$files" -eq 0 ]] && \
		      result+=( "$file" )

		      ((files++))
		      break
		  else
		      result+=( "${line0:="$line"}" )
		  fi
		fi
	      fi
	    else
	      # Not -x
	      if [[ ${Opts["v"]} -eq 1 ]]
	      then
	        if [[ ! "$line" =~ $Pattern ]]
	        then
		  positive=1
	      	  if [[ ${Opts["l"]} -eq 1 ]]
	          then
		      [[ "$files" -eq 0 ]] && \
		      result+=( "$file" )

		      ((files++))
		      break
		  else
		      result+=( "${line0:="$line"}" )
		  fi
		fi
	      else
		# Not -v
	        if [[ "$line" =~ $Pattern ]]
	        then
		  positive=1
	      	  if [[ ${Opts["l"]} -eq 1 ]]
	          then
		      [[ "$files" -eq 0 ]] && \
		      result+=( "$file" )

		      ((files++))
		      break
		  else
		      result+=( "${line0:="$line"}" )
		  fi
		fi
	      fi
	    fi 
		    
	    # One last option to check..
	    #  nb: this is weirdo, I know ! :/
	    #
	    [[ "${Opts["n"]}" -eq 1 ]] \
	 && [[ "$positive" -eq 1 ]] \
	 && strt="$(("${#result[@]}" - 1))" \
	 && result["$strt"]="$line_no"':'"${result["$strt"]}"

	    [[ "$file2" -gt 1 ]] \
	 && [[ "$positive" -eq 1 ]] \
	 && strt="$(("${#result[@]}" - 1))" \
	 && result["$strt"]="$file"':'"${result["$strt"]}"

	    ((line_no++))

	done < <(cat "$file")
    
      for i in $(seq 0 $(("${#result[@]}" - 1)))
      do
	    printf "%s\n" "${result["$i"]}"
      done
    
     done
}


main () {

    # Filled with store_Input() 
    # called in test_regex()
    #   ( nearly the very same as "$@" )
    #
    declare -A Opts=( )	
    declare -a Input=( )

    # Flat string version
    declare Input2=""

    # Test arguments
    test_params "$@"

    Return=$?

    # Process
    case "$Return" in
	    0)
		# Imput[0] is pattern
		#  all remaining are files names
		#
		mk_grep_files "${Input[@]}"
		    ;;
	    *)
		printf2 "An Invalid Input Occurred"
	        exit 1 
		    ;;
    esac

    exit 0
}


# Call main with all of the positional arguments
   main "$@"

