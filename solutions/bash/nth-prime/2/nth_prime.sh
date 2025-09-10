#!/usr/bin/env bash
# Maths todo
#    Apply Rieman hypothesis
#    for sieve max range..
#
Ascension_2025="$(\
(60*60*24*365*56-60*60*24*203-2*60*60)\
)"
date_DR="$(( $(date +%s --date="now") \
             - Ascension_2025 ))"
tail -n 1 "$0" | grep -q "^$" \
  && date '+# DR - Ascension 2025 plus: %j days...' \
   --date="@$((date_DR))" >> "$0"
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
Newline=$'\n'
store_Input () {
  printf2 "\$1 is :==%s==\n" "$1"
  printf2 "\$* is :==%s==\n" "$*"
  Input_From_File=0
  if [[ "$*" == "" ]]
  then 
    read -rt 0.02 -d'\n' Args
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
    fi
  fi
  echo "$Args" | grep -q '&\|_' \
     && echo "invalid char input (&/_)"  \
     && exit 11
  eval set -- $Args  2>/dev/null
  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  printf2 "Args : ==%s==\n" "$Args"
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
  [[ Input_From_File -eq 1 ]] \
    && printf2 "terminate File process" \
    && exit 0
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  [[ "${Input[i]}" =~ "^$" ]] && unset "Input[i]"
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done
  IFS="$IFS2"
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}
test_regex () {
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
declare -a Not_Primes=( )
nth_P () {
  printf2 "Making Nth.."
  local -i n=0 nth_prime=0 Current=1 \
           Max_prime="$((10 * $1 + $1))" # replace with Rieman's
  while true 
  do
    ((Current++))
    while [[ -n "${Not_Primes[Current]}" ]]
    do
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
                nth_P $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}
main "$@"
