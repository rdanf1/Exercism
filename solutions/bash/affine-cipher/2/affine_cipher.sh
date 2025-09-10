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
declare -i M=26 j=0
for i in {a..z}
do
  Alpha_Aar+=( ["$i"]="$j" )
  ((j++))
done
printf2 "Alpha_ar :" "${Alpha_ar[0]}"
printf2 "Alpha_Aar :" "${Alpha_Aar["a"]}"
store_Opts () {      #  '+:' means optº comes as 1st args!
  { ! TEMP0=$(getopt -o "+xy:k:z::" -n "$0" -- "$@") ;} \
     && printf2 "%s" 'getopt error...' >&2
  printf2 "TEMP0 :" "$TEMP0"
  [ "$TEMP0" == "" ] && return 2
  # to un-quote ?
  eval set -- "$TEMP0"
  printf2 "TEMP0 after eval set :" "$TEMP0"
  while true
  do
    case "$1" in
      '-'[a-z] )  
                opt="${1/-/}"
                Opts+=( ["$opt"]=1 )
                printf2 "!Opts :" "${!Opts[@]}"
                printf2 "Opts :" "${Opts[@]}"
                Args="${Args/$1/}"    # remove opt
                Args="${Args/$'\n'/}" # need this!
                shift
                ;;
          '--' )   
                shift
                break
                    ;;
      +([a-z]) )  
                Opts["$opt"]="$1"
                Args="${Args/$1$'\n'/}" # if not sticky! 
                Args="${Args/$1/}"      # else (sticky)
                printf2 "Opts :" "${Opts[@]}"
                shift
                ;;
            '' )  
                printf2 "Opts Warning:" "Null Chain Value"
                  printf2 "Opts is ====> -%s\n" "$opt"
                  shift
                  ;;
             * )  
                printf2 "%s" 'Opts Invalid value !' >&2
                printf2 'Opts Removing %s !' "$opt" >&2
                Args="-$opt"$'\n'"$Args"
                unset "Opts[$opt]"
                printf2 "!Opts :" "${!Opts[@]}"
                printf2 "Opts :" "${Opts[@]}"
                return 2 
                ;;
    esac
  done
}
store_Input () {
  # No regression : keeping previous forms.
  # Reading from '<<< "Ansi-C string", or a File
  # or Classical arguments and their options if any.
  # Todo : implies self calls for each line with args
  #        implies input types caracterisation (3)
  printf2 "\$1 is :==%s==\n" "$1"
  printf2 "\$* is :==%s==\n" "$*"
  if [[ "$*" == "" ]]
  then 
    read -rt 0.02 -d'\n' Args
  else
    if [[ -e "$*" ]]
    then
      Args=$(cat "$*" 2>/dev/null) || \
        { echo "Input File issue.." >&2
          exit 33
        }
    else
      Args="$*"
    fi
  fi
  # " ' & ( ) ` |     <,> : $'\x3c', $'\x3e'
  # Those above chars fails 'eval set -- $var'
  #  and '&' is unstoppable..
  #  .. though stopped here, 
  #     (plus subst. chr, ie '_', if any used later)
  echo "$Args" | grep -q '&\|_' \
     && echo "invalid char input (&/_)"  \
     && exit 11
  # Restitution to standard positionnal arguments
  #  ( if '<<< ..' or 'File' form input was used.. )
  # nb: no quotes here lost input lines..
  #  (though they arn't needed later because '$Args' 
  #  is untouched exept if any options are given 
  #  they're cutted from it)
  #   'eval set' issue: 
  #         errors occurs if Args quoted and $'\n'
  #         unquoted and $';' ..
  #
  # nb : this is needed only to manage/store
  #      options on next instruction 'store_Opts'
  #
  #eval set -- "${Args//';'/_}"  2>/dev/null
  eval set -- $Args  2>/dev/null
    # || { echo "invalid input" && exit 1 ;}
  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  #printf2 "Args2 ';' subst '_' : ==%s==\n" "${Args//$';'/_}"
  printf2 "Args : ==%s==\n" "$Args"
  # Opts losts initials input lines
  #  once stripped with 'getopt'
  #   => Truncating above '$Args' directly = Ok
  store_Opts "$@"
  i=0
  while read -r Input["i"]
  do
    :
    ((i++))
  done < <(echo "$Args")
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  # Last value is an empty line  => to remove !
  unset "Input[i]"
  # Debuging check
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done
  IFS="$IFS2"
  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  Input2="${Input[*]//[[:punct:]]/}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}
test_regex () {
REGEX_PARAM=\
'\(encode\|decode\)'
REGEX_PARAMM=\
'[[:digit:]]\+'
REGEX_PARAMN=\
'[[:alpha:]]\+'
REGEX_PARAMS=\
"^$REGEX_PARAM\( $REGEX_PARAMM\)\{2\} $REGEX_PARAMN$"
REGEX_PARAM1=\
'(encode|decode)'
REGEX_PARA11=\
'[[:digit:]]'
REGEX_PARA22=\
'[[:alpha:]]'
REGEX_PARAM2=\
"^$REGEX_PARAM1( $REGEX_PARA11+){2}\
( +($REGEX_PARA22|$REGEX_PARA11)+)+$"
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
  test_regex "$Args"
  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
      printf2 "Input Wrong Regex"
echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
     "     or $0 [file]"$'\n'\
     "with    $0 [encode/decode] <a> <b> <string>"
      return 1
  else
      check_Args
      case "${Input[0]}" in
    'encode' ) return 1
             ;;
    'decode' ) return 2
             ;;
              *  ) echo 'never happens'
      esac
      printf2 "Arguments Ok !"
      return 0
  fi
}
co_Primes () {
  factors2_regex="$( \
    factor "$2" | sed 's/.*: \?//' \
                | sed 's/ /\\|/g' )"
  factors1="$( \
    factor "$1" | sed 's/.*: \?//' )"
  printf2 "factors2 reg :" "$factors2_regex"
  printf2 "factors1     :" "$factors1"
  ! echo "$factors1" \
    | grep -q "\($factors2_regex\)"
  return $?
}
Mmi () {
  local -i i=1
  while [[ $((("$1" * "$i") % "$2")) -ne 1 ]]
  do
    ((i++))
  done
  echo "$i"
}
mk_Code () {
  local -i enc=0 i=0 j=0 m=26 mmi=0
  [ "$1" == "encode" ] \
    && enc=1           \
    || mmi="$(Mmi "$2" "$m")"
  printf2 "mmi :" "$mmi"
  shift
  local -i a="$1" b="$2"
  shift ; shift
  local chain="$*"
  chain="${chain//[[:punct:]]/}"
  chain="${chain// /}"
  chain="${chain@L}"
  printf2 "chain :%s" "$chain"
  while [[ "${#chain}" -ne 0 ]]
  do
    [[ "$j" -eq 5 ]] \
      && [[ "$enc" -eq 1 ]] \
      && printf ' ' && j=0
    ((j++))
    chr="${chain:0:1}"
    [[ "$chr" =~ ^[[:digit:]]$ ]] \
      && printf "%s" "$chr" \
      && chain="${chain:1}" \
      && continue
    i="${Alpha_Aar[$chr]}"
    case "$enc" in
      1) 
        result1="$(bc <<<"($a * $i + $b) % $m")"
        ;;
      0)
        result1="$(bc <<<"(( $i - $b ) *  $mmi ) % $m")"
        #printf2 "result1 :" "$result1"
        ;;
     -1)
    esac
    result="${Alpha_ar[$result1]}"
    printf "%s" "$result"
    chain="${chain:1}"
  done
  printf "\n"
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
      '1'|'2')  
                co_Primes "$2" "$M" \
                  || { echo "a and m must be coprime."
                       exit 11
                     }
                mk_Code $Args
                ;;
            *)  
                printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}
main "$@"
