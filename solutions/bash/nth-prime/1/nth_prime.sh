#!/usr/bin/env bash
# DR - Signature :
Ascension_2025="$(\
(60*60*24*365*56-60*60*24*203-2*60*60)\
)"
date_DR="$(( $(date +%s --date="now") \
             - Ascension_2025 ))"
tail -n 1 "$0" | grep -q "^$" \
  && date '+# DR - Ascension 2025 plus: %j days...' \
   --date="@$((date_DR))" >> "$0"

# Debug mode printf
DEBUG=0

printf2 () {
  if [[ "$DEBUG" -gt "0" ]]
  then
    if [[ "$1" =~ '%' ]]
    then
        printf "$@"
    else
        printf '%s\n' "$*"
    fi
  fi
  return 0
}

# Begin
#
Newline=$'\n'

store_Input () {
  # No regression : keeping previous forms.
  # Reading from '<<< "Ansi-C string", or a File
  # or Classical arguments and their options if any.
  #
  printf2 "\$1 is :==%s==\n" "$1"
  printf2 "\$* is :==%s==\n" "$*"

  # Enabled 'Input_From_File' mode
  #   (assuming each line is a set of args for $0
  #    this may mess up multiple lines input scripts,
  #    $0 errors arn't managed.. )
  # test several sets of args ie : 
  #     $0 <<< $(echo {1..22}$'\n'<2d set>$'\n'<3rd...
  Input_From_File=0
  if [[ "$*" == "" ]]
  then 
    read -rt 0.02 -d'\n' Args
    # read returns "exotic" values..
    #  => test on $Args is required.
    [ "$Args" != "" ] && \
      Input_From_File=1
  else
    if [[ -e "$*" ]]
    then
      Args=$(cat "$*" 2>/dev/null) && \
      Input_From_File=1            || \
        { echo "Input File issue.." >&2
          exit 33
        }
    else
      Args=$(echo "$*" | xargs)
      #Args="$*"
    fi
  fi
  # " ' & ( ) ` |     <,> : $'\x3c', $'\x3e'
  # Those above chars fails 'eval set -- $var'
  #  and '&' is unstoppable..
  #  .. though stopped here, 
  #     (plus subst. chr, ie '_', if any use later)
  echo "$Args" | grep -q '&\|_' \
     && echo "invalid char input (&/_)"  \
     && exit 11

  # Restitution to standard positionnal arguments
  #  ( if '<<< ..' or 'File' form input was used.. )
  # nb: no quotes here lost input lines..
  #
  eval set -- $Args  2>/dev/null
    # || { echo "invalid input" && exit 1 ;}
  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  #printf2 "Args2 ';' subst '_' : ==%s==\n" "${Args//$';'/_}"
  printf2 "Args : ==%s==\n" "$Args"

  # fill Input[] with args
  #  ( if args were taken from file - or <<< -
  #     call self foreach line )
  #
  i=0
  while read -r Input["i"]
  do
    if [[ Input_From_File -eq 1 ]]
    then
      $0 ${Input[i]}
    else
      break
    fi
    ((i++))
  done < <(echo "$Args")

  # If "from file" all sets of args
  #  (1 per line) were processed above..
  #  => quit ( $0 return isnt managed )
  [[ Input_From_File -eq 1 ]] \
    && printf2 "terminate File process" \
    && exit 0
  
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  # Last value is an empty line  => to remove !
  [[ "${Input[i]}" =~ "^$" ]] && unset "Input[i]"

  # Debuging check
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done
  
  IFS="$IFS2"
  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  #Input2="${Input[*]// /_}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}

test_regex () {
# Conforms with @tests input pattern 
#        
REGEX_PARAM1=\
'[[:digit:]]*'
REGEX_PARAM2=\
"^[1-9]+$REGEX_PARAM1$" 

  [[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}

test_params () {

  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)

  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
      [[ "$Input2" -lt 0 ]] \
        && printf2 "0th error" \
        && echo "invalid input" && exit 1

      [[ "$Input2" -eq 0 ]] \
        && printf2 "0th error" \
        && echo "invalid input" && exit 1
             
      printf2 "Input Wrong Regex"
echo " Usage : $0 [<File>] or [<<< $'Ansi-C string'] or [<str>]]"
echo " With  : Single Integer Parameter set : [<Nth Prime>] "
      return 1
  else




      printf2 "Arguments Ok !"
      return 0
  fi
}

# global : May improve multiple sets 
#          with file mode ?
#
declare -a Not_Primes=( )

nth_P () {
  printf2 "Making Nth.."
  local -i n=0 nth_prime=0 Current=1 \
           Max_prime="$((10 * $1 + $1))"
# Optimal value as low as possible is necessary
#           Max_prime="$((2 ** 17))"
#           Max_prime=105000

  while true 
  do
    ((Current++))

    while [[ -n "${Not_Primes[Current]}" ]]
    do
	    #printf2 "is tagged so jumping.."
	    ((Current++))
    done

    ((nth_prime++))

	[[ "$nth_prime" -eq "$1" ]] \
     && Prime="$Current" \
     && echo "$Prime" && return 0

	n="$Current"
	while [[ "$n" -lt "$Max_prime" ]]
	do
		n+="$Current"
        Not_Primes[n]=0
	    #printf2 "sieving.. : %i" "$n"
    done
  done
}


main () {
    IFS2="$IFS"
    IFS="$Newline"

    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
      '0'|'1')  # Note : Args are passed unquoted
                #      ( Otherwise only $1 exists! )
                nth_P $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 079 days...
