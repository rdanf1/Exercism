#!/usr/bin/env bash
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
declare -a Week_Days=( )
for i in {0..6}
do
  Week_Days+=( "$(date +%A --date="01/01/1900 +$i day")" )
  printf2 "Week_Day %i is %s\n" "$i" "${Week_Days[i]}"
done
declare -ar Meet_Type=( \
  "teenth" "first" "second" "third" "fourth" "last" )
for i in {0..5}
do
  printf2 "Meet_Type %i is %s\n" "$i" "${Meet_Type[i]}"
done
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
      Args="$*"
    fi
  fi
  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  printf2 "Args : ==%s==\n" "$Args"
  i=0
  while read -r Input["i"]
  do
    if [[ Input_From_File -eq 1 ]]
    then
      $0 ${Input[i]}
    else
      :
    fi
    ((i++))
  done < <(echo "$Args")
  [[ Input_From_File -eq 1 ]] \
    && printf2 "terminate File process" \
    && exit 0
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  if [[ "${Input[i]}" =~ "^$" ]] ||
     [[ "${#Input[i]}" -eq 0 ]]
  then
    unset "Input[i]"
  fi
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : ==%s==\n" "$i" "${Input[i]}"
  done
  IFS=$' \t\n'    # Reset Default values for Input Separators
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}
test_regex () {
REGEX_PARAM=\
'[[:digit:]]+'
REGEX_PARAMS=\
"$(echo "${Meet_Type[*]}" | tr ' ' '|')"
printf2 "reg3 :" "$REGEX_PARAMS"
REGEX_PARAM1=\
"$(echo "${Week_Days[*]}" | tr ' ' '|')"
printf2 "reg4 :" "$REGEX_PARAM1"
REGEX_PARAM2=\
"^$REGEX_PARAM $REGEX_PARAM ($REGEX_PARAMS) ($REGEX_PARAM1)$" 
  [[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}
test_params () {
  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)
  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
      printf2 "Input Wrong Regex"
echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
      "     or $0 [file]"$'\n'\
      "with    $0 <year> <month> <meet-type> <week-day>"
      return 1
  else
      printf2 "Arguments Ok !"
      return 0
  fi
}
while_Decr () {
   while [ "$(date +%A --date="$1-$2-$Dat1")" != "$3" ]
   do
       ((Dat1--))
   done
 }
while_Incr () {
   while [ "$(date +%A --date="$1-$2-$Dat1")" != "$3" ]
   do
       ((Dat1++))
   done
 }
mk_Meet () {
  printf2 "Making Sth.."
  case "$3" in
    'teenth')
              printf2 "Making teenth.."
              Dat1=13
              while_Incr "$1" "$2" "$4"
              ;;
     'first')
              printf2 "Making first.."
              Dat1=1
              while_Incr "$1" "$2" "$4"
              ;;
    'second')
              printf2 "Making second.."
              Dat1=1
              while_Incr "$1" "$2" "$4"
              Dat1=$((Dat1 + 7))
              ;;
     'third')
              printf2 "Making third.."
              Dat1=1
              while_Incr "$1" "$2" "$4"
              Dat1=$((Dat1 + 14))
              ;;
    'fourth')
              printf2 "Making fourth.."
              Dat1=1
              while_Incr "$1" "$2" "$4"
              Dat1=$((Dat1 + 21))
              ;;
      'last')
              printf2 "Making last.."
              Dat1="$(date +%d \
                    --date="$1-$2-1 +1 month -1 day")"
              while_Decr "$1" "$2" "$4"
              ;;
  esac      
  result="$(date --iso-8601 --date="$1-$2-$Dat1")"
  echo "$result"
}
main () {
    IFS="$Newline"
    Args=""
    declare -a Input=( )
    declare Input2=""
    test_params "$@"
    case "$?" in
          '0')  # Note : Args are passed unquoted
                mk_Meet $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}
main "$@"

# DR - Ascension 2025 plus: 084 days...
