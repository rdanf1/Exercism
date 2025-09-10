#!/usr/bin/env bash
# Signature DR !
#
Ascension_2025=$(\
(60*60*24*365*56-60*60*24*203-2*60*60)\
)
date_DR="$(($(date +%s --date="now") - Ascension_2025))"
tail -n 1 "$0" | grep -q "^$" \
  && date '+# DR - Ascension 2025 plus: %j days...' \
   --date="@$((date_DR))" >> "$0"
# Begin
#
shopt -s extglob
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
store_Opts () {      #  '+:' means optº comes as 1sts args!
  { ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 "%s" 'getopt error...' >&2
        [ "$TEMP0" == "" ] && return 2
  eval set -- "$TEMP0"
  while true
  do
      case "$1" in
  '-'[a-z] )  opt="${1/-/}"
    Opts+=( ["$opt"]=1 )
    Args="${Args/ $1 /}"  # 1st opt (or..)
    Args="${Args/$1 /}"   # nth opt (or..)
        Args="${Args/$1/}"    # sticky opt
    shift
    ;;
      '--' )   shift
    break
    ;;
  +([a-z]) )  Opts["$opt"]="$1"
        Args="${Args/$1 /}"
    shift
    ;;
  '' )  printf2 "Opts Warning:" "Null Chain Value"
    shift
    ;;
   * )  printf2 "%s" 'Opts Invalid value !' >&2
    Args="-$opt $Args"
    unset "Opts[$opt]"
    return 2 
    ;;
      esac
  done
}
mk_Scores_header () {
  echo \
"Team                           | MP |  W |  D |  L |  P"
}
set_Scores () {
   line_in="$1"
  score="${line_in/*;/}"
  team1="${line_in/;*/}"
  echo "${Team[@]}"  | grep -q "$team1" \
     || Team+=( "$team1" )
  _team1="${team1// /_}"
  declare team1_P="$_team1"'_P' \
          team1_M="$_team1"'_M' \
    team1_W="$_team1"'_W' \
    team1_D="$_team1"'_D'
  team2="${line_in/$team1;/}"
  team2="${team2/;$score/}"
  echo "${Team[@]}"  | grep -q "$team2" \
     || Team+=( "$team2" )
  _team2="${team2// /_}"
  declare team2_P="$_team2"'_P' \
          team2_M="$_team2"'_M' \
    team2_W="$_team2"'_W' \
    team2_D="$_team2"'_D'
  Teams["$team1_M"]="$((${Teams["$team1_M"]:=0} + 1))"
  Teams["$team2_M"]="$((${Teams["$team2_M"]:=0} + 1))"
case "$score" in
'win' ) 
  Teams["$team1_P"]="$((${Teams["$team1_P"]:=0} + 3))"
  Teams["$team1_W"]="$((${Teams["$team1_W"]:=0} + 1))"
  Teams["$team1_D"]="$((${Teams["$team1_D"]:=0} + 0))"
  Teams["$team2_P"]="$((${Teams["$team2_P"]:=0} + 0))"
  Teams["$team2_W"]="$((${Teams["$team2_W"]:=0} + 0))"
  Teams["$team2_D"]="$((${Teams["$team2_D"]:=0} + 0))"
        ;;
'loss') 
  Teams["$team1_P"]="$((${Teams["$team1_P"]:=0} + 0))"
  Teams["$team1_W"]="$((${Teams["$team1_W"]:=0} + 0))"
  Teams["$team1_D"]="$((${Teams["$team1_D"]:=0} + 0))"
  Teams["$team2_P"]="$((${Teams["$team2_P"]:=0} + 3))"
  Teams["$team2_W"]="$((${Teams["$team2_W"]:=0} + 1))"
  Teams["$team2_D"]="$((${Teams["$team2_D"]:=0} + 0))"
        ;;
'draw')
  Teams["$team1_P"]="$((${Teams["$team1_P"]:=0} + 1))"
  Teams["$team1_W"]="$((${Teams["$team1_W"]:=0} + 0))"
  Teams["$team1_D"]="$((${Teams["$team1_D"]:=0} + 1))"
  Teams["$team2_P"]="$((${Teams["$team2_P"]:=0} + 1))"
  Teams["$team2_W"]="$((${Teams["$team2_W"]:=0} + 0))"
  Teams["$team2_D"]="$((${Teams["$team2_D"]:=0} + 1))"
        ;;
* )
  [[ "${Input[0]}" == "" ]] \
     && mk_Scores_header && exit 0
  echo "Invalid (case) input"
  exit 11
        ;;
esac
}
store_Input () {
  if [[ "$*" == "" ]]
  then 
    read -r -d'\n' Args
  else
    Args=$(cat "$*" 2>/dev/null) \
     || { echo "Wrong File name" ; exit 1 ;}
  fi
  echo "$Args" | grep -q '&\|_' \
     && echo "invalid input (&/_)"  \
     && exit 11
  eval set -- "${Args//';'/_}"  2>/dev/null \
  store_Opts "$@"
  i=0
  while read -r Input["i"]
  do
    set_Scores "${Input[i]}"
    ((i++))
  done < <(echo "$Args")
  unset "Input[i]"
  for i in "${!Input[@]}"
  do
    :
  done
  Input2="${Input[*]// /_}"
}
test_regex () {
REGEX_PARAM=\
''
REGEX_PARAMM=\
'[[:print:]]*'
REGEX_PARAMS=\
"^$REGEX_PARAM$REGEX_PARAMM$"
REGEX_PARAM1=\
''
REGEX_PARA11=\
'([[:print:]]*$)*'    # =~ is trickier than grep :
REGEX_PARAM2=\
"^$REGEX_PARAM1$REGEX_PARA11"  # removed trailing $ (!fails)
  printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     && printf2 $? \
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
        :
      fi
   else
     :
  fi
    done
}
test_params () {
  store_Input "$@"
  test_regex "$Args"
  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
echo "Usage : $0 [<<< $'Ansi-C string' or \"\$str\"] \
          or $0 [file]"
      return 1
  else
      check_Args
      return 0
  fi
}
mk_Scores () {
        IFS="$IFS2"
  results=""
        mk_Scores_header
  for i in "${!Team[@]}"
  do
    team_M="${Team[i]// /_}"'_M'
    team_W="${Team[i]// /_}"'_W'
    team_D="${Team[i]// /_}"'_D'
    team_P="${Team[i]// /_}"'_P'
   local -i n=31
   local str="${Team[i]}"
   dots=$(printf "%.0s " $(seq $((n-${#str})) ))
   results+=$(printf "%s%s|" "$str" "$dots")
for j in "$team_M" "$team_W" "$team_D" "" "$team_P"
do
  local -i str2=0 size_str2=1
  if [ "$j" == "" ]
  then
    str2="$((Teams["$team_M"] - Teams["$team_W"] \
          - Teams["$team_D"] ))"
  else
    str2="${Teams[$j]}"
  fi
  n=2
  [[ "$str2" -ge 10 ]] && size_str2=2
  dot1=$( printf "%.0s " $(seq $n) )
  dot2=$( printf "%.0s\b" $(seq $size_str2) )
  if [ "$j" == "$team_P" ] 
  then
    results+=$(printf " %s%s%i" "$dot1" "$dot2" "$str2")
  else  
    results+=$(printf " %s%s%i |" "$dot1" "$dot2" "$str2")
  fi
done
      results+=$'\n'
  done
  IFS=$'\b'
  results="${results// $'\b'/}"
  results="${results// $'\b'/}"
  echo    "$results"           | \
    grep -v "^$"         | \
    sort -t '|' -k 6rn 
}
main () {
    IFS2="$IFS"
    IFS=$'\n'
    declare -a Team=( )
    declare -A Teams=( )
    declare TEMP0=""
    declare -A Opts=( )
    Args=""
    declare -a Input=( )
    declare Input2=""
    test_params "$@"
    case "$?" in
      0)  mk_Scores "$@"
        ;;
      *)  printf2 "An Invalid Input Occurred"
          exit 1
        ;;
    esac
    exit 0
}
main "$@"

# DR - Ascension 2025 plus: 072 days...
