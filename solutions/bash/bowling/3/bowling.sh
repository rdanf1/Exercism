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
shopt -s extglob
Newline=$'\n'
declare -a Alpha_ar=( {a..z} )
declare -A Alpha_Aar=( )
declare -i j=0
for i in {a..z}
do
  Alpha_Aar+=( ["$i"]="$j" )
  ((j++))
done
printf2 "Alpha_ar :" "${Alpha_ar[0]}"
printf2 "Alpha_Aar :" "${Alpha_Aar["a"]}"
store_Opts () {      #  had to add '$not_stky' for cancel/cut 
  { ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 "%s" 'getopt error...' >&2
  [ "$TEMP0" == "" ] && return 2
  eval set -- "$TEMP0"
  printf2 "TEMP0 after eval :" "$TEMP0"
  while true
  do
    case "$1" in
      '-'[a-z] )  
                opt="${1/-/}"
                Opts+=( ["$opt"]=1 )
                Args="${Args/ $1/}"    # remove opt
                Args="${Args/$1/}"    # or remove opt
                [[ "${Args:0:1}" == ' ' ]] \
                  && Args="${Args/ /}"   \
                  && not_stky=1              \
                  || not_stky=0       # need these !
                printf2 "Args         : \n%s\n" "$Args"
                printf2 "not sticky opt ? %s\n" "$not_stky"
                shift
                ;;
          '--' )   
                printf2 "End of options process" \
                shift
                break
                ;;
      +([a-z]) )  
                Opts["$opt"]="$1"
                Args="${Args/ $1 /}"    # else not sticky ! 
                Args="${Args/$1 /}"     # else is sticky  ! 
                printf2 "Args         : \n%s\n" "$Args"
                shift
                ;;
            '' )
                printf2 "Opt %s : Warning Null value" \
                        "$opt"
                shift
                ;;
             * ) 
                printf2 "Opt %s : Wrong value, removing.." \
                        "$opt"
                [[ "$not_stky" -eq 1 ]] \
                && Args="-$opt"" $Args" \
                || Args="-$opt""$Args"
                printf2 "Args         : \n%s\n" "$Args"
                unset "Opts[$opt]"
                return 2  # An error value stops opt browsing..
                ;;        # and option is restored as regular arg
    esac
  done
  printf2 "\n!Opts : ==%s\n==" "${!Opts[@]}"
  printf2 "\n@Opts : ==%s\n==" "${Opts[@]}"
}
store_Input () {
  printf2 "\$1 is :==%s==\n" "$1"
  printf2 "\$* is :==%s==\n" "$*"
  Input_From_File=0
  if [[ "$*" == "" ]]
  then 
    read -rt 0.02 -d'\n' Args
    [ "$Args" != "" ] \
      && Input_From_File=1
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
  store_Opts "$@"
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
  [[ ! -v "${Input[i]}" ]] || unset "Input[i]"
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done
  IFS="$IFS2"
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}
test_regex () {
REGEX_PARAM=\
'[[:digit:]]\+'
REGEX_PARAMS=\
"^$REGEX_PARAM\( $REGEX_PARAM\)\{11,20\}$"
REGEX_PARAM1=\
'[[:digit:]]+'
REGEX_PARAM2=\
"^$REGEX_PARAM1( $REGEX_PARAM1){11,20}$" 
  printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual ! (grep)'
  [[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}
check_Args () {
    opts=0
    [ ! -v "$TEMP0" ] \
 && eval set -- "$TEMP0" && opts=1
    for arg
    do  
      if [[ "$opts" -eq 1 ]]
      then
        if [ "$arg" == '--' ]
        then
          opts=0
        else
          printf2 "Opt arg :     %s\n" "$arg"
        fi
      else  
          printf2 "regular arg : %s\n" "$arg"
      fi
    done
}
test_params () {
  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)
      if echo "$Input2" | grep -q "1[1-9]"
      then
        echo "Pin count exceeds pins on the lane" \
        && exit 1
      fi
  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
      [ "$Input2" == "" ] \
  && echo "Score cannot be taken until the end of the game" \
        && exit 11
      [[ "$Input2" =~ -[[:digit:]]+ ]] \
        && echo "Negative roll is invalid" \
        && exit 1
      if [ ! "$(echo "$Input2" | cut -d' ' -f 22)" == "" ]
      then
        echo "Cannot roll after game is over"
        exit 111
      fi
      printf2 "Input Wrong Regex"
      return 1
  else
      _19th="$(echo "$Input2" | cut -d' ' -f 19)"
      _20th="$(echo "$Input2" | cut -d' ' -f 20)"
      _21th="$(echo "$Input2" | cut -d' ' -f 21)"
      if  { [ "$_20th" == "10" ] || \
           [[ $((_19th + _20th)) -eq 10 ]] ;} \
        && [ "$_21th" == "" ]
      then
        echo "Score cannot be taken until the end of the game"
        exit 56
      fi
      check_Args
      printf2 "Arguments Ok !"
      return 0
  fi
}
mk_Score () {
  printf2 "Making Score.."
  local -a args=( $Args )
  local -i i=0 rolls=0 score=0 sum1=0
  while [ "${args[i]}" != "" ]
  do
      printf2 "score : $score"
      ((rolls++))
      [[ "$rolls" -gt 10 ]] && break
      if [ "${args[i+1]}" != "" ]
      then
        sum1=$(( args[i] + args[i+1] ))
        printf2 "sum1 : $sum1"
        if [ "${args[i+2]}" != "" ]
        then
             sum2=$(( args[i+1] + args[i+2] ))
        else
             sum2="${args[i+1]}"
        fi
      else
        break
      fi
      if [[ "${args[i]}" -eq 10 ]]
      then
         printf2 "Strike !!!"
         [[ $sum2 -gt 10 ]] \
      && [[ "${args[i+1]}" -ne 10 ]] \
      && [[ "${args[i+2]}" -ne 10 ]] \
      && [[ "$rolls" -eq 10 ]] \
      && echo "Pin count exceeds pins on the lane" \
      && exit 22
         [[ "${args[i+2]}" -eq 10 ]] \
      && [[ "${args[i+1]}" -ne 10 ]] \
      && [[ "$rolls" -eq 10 ]] \
      && echo "Pin count exceeds pins on the lane" \
      && exit 22
         score+="$(( sum1 + args[i+2] ))"
         ((i++)) ; prev_st=1
         continue
      fi
      [[ $sum1 -gt 10 ]] \
      && echo "Pin count exceeds pins on the lane" \
      && exit 22
      if [[ $sum1 -eq 10 ]]
      then
         printf2 "Spair !"
         score+=$(( sum1 + args[i+2] ))
         ((i+=2)) ; prev_st=2
         continue
      fi
      if  [[ "$prev_st" -eq 1 ]] || \
          [[ "$prev_st" -eq 2 ]]
      then
            [ "${args[i+2]}" == "" ] \
            && [[ "$rolls" -eq 10 ]] \
            && break
      fi
      score+="$sum1"
      ((i+=2)) ; prev_st=0
  done
      [[ "$rolls" -lt 10 ]] \
  && echo "Score cannot be taken until the end of the game" \
        && exit 22
      [[ "$rolls" -eq 11 ]] \
        && [[ "$prev_st" -eq 0 ]] \
        && [ "${args[i]}" != "" ] \
        && echo "Cannot roll after game is over" \
        && exit 33
      [[ "$rolls" -eq 11 ]] \
        && [[ "$prev_st" -eq 1 ]] \
        && [ "${args[i]}" == "" ] \
  && echo "Score cannot be taken until the end of the game" \
        && exit 44
  echo "$score"
}
main () {
    IFS2="$IFS"
    IFS="$Newline"
    declare TEMP0=""
    declare -A Opts=( )
    Args=""
    declare -a Input=( )
    declare Input2=""
    test_params "$@"
    case "$?" in
  '0'|'1'|'2')  # Note : Args are passed unquoted
                mk_Score $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}
main "$@"

# DR - Ascension 2025 plus: 078 days...
