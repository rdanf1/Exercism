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
store_Opts () {      #  had to add '$not_stky' for cancel/cut 
                     #     modes to work properly..
                     #  '+:' means optº comes as 1st args!
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
                Args="${Args/$1/}"    # remove opt
                [[ "${Args:0:1}" == $'\n' ]] \
                  && Args="${Args/$'\n'/}"   \
                  && not_stky=1              \
                  || not_stky=0       # need these !
                printf2 "Args         : \n%s\n" "$Args"
                printf2 "not sticky opt ? %s\n" "$not_stky"
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
                [[ "$not_stky" -eq 1 ]] && \
                Args="-$opt"$'\n'"$Args" \
                || Args="-$opt""$Args"
                unset "Opts[$opt]"
                return 2  # An error value stops opt browsing..
                ;;        # and option is restored as regular arg
    esac
  done
  # Nothing in there if no options(+val) provided
  #  ( options *as defined* in 'getopt ..' statement above..)
  printf2 "\n!Opts : ==%s\n==" "${!Opts[@]}"
  printf2 "\n@Opts : ==%s\n==" "${Opts[@]}"
}
store_Input () {
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
  echo "$Args" | grep -q '&\|_' \
     && echo "invalid char input (&/_)"  \
     && exit 11
  eval set -- $Args  2>/dev/null
  store_Opts "$@"
  i=0
  while read -r Input["i"]
  do
    printf2 "Input["i"] :" "${Input[i]}"
    ((i++))
  done < <(echo "$Args")
  unset "Input[i]"
  for i in "${!Input[@]}"
  do
    :
  done
  IFS="$IFS2"
  Input2="${Input[*]}"
  printf2 "Input2 :" "$Input2"
  Input2="${Input[*]//[[:punct:]]/}"
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
          printf2 "Opt     arg :" "$arg"
        fi
      else
          printf2 "Regular arg :" "$arg"
      fi
    done
}
test_params () {
  store_Input "$@"
  test_regex "$Args"
  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then
echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
     "     or $0 [file]"$'\n'\
     "with    $0 [encode/decode] <a> <b> <string>"
      return 3
  else
      check_Args
      case "${Input[0]}" in
    'encode' ) return 1
             ;;
    'decode' ) return 2
             ;;
          *  ) echo 'never happens'
      esac
      return 0
  fi
}
co_Primes () {
  factors2_regex="$( \
    factor "$M" | sed 's/.*: \?//' \
                | sed 's/ /\\|/g' )"
  factors1="$( \
    factor "$2" | sed 's/.*: \?//' )"
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
  # Note : printf command is to be postponed
  #        because appending a char to a string
  #        is faster than print it !
  #
  local -i enc=0 i=0 j=0 m=26 mmi=0
  [ "$1" == "encode" ] \
    && enc=1           \
    || mmi="$(Mmi "$2" "$m")"
  shift
  local -i a="$1" b="$2"
  shift ; shift
  local chain="$*"
  chain="${chain//[[:punct:]]/}"
  chain="${chain// /}"
  chain="${chain@L}"
  while [[ "${#chain}" -ne 0 ]]
  do
    [[ "$j" -eq 5 ]] \
      && [[ "$enc" -eq 1 ]] \
      && result+=' ' && j=0
    ((j++))
    chr="${chain:0:1}"
    [[ "$chr" =~ ^[[:digit:]]$ ]] \
      && result+="$chr" \
      && chain="${chain:1}" \
      && continue
    i="${Alpha_Aar[$chr]}"
    case "$enc" in
      1) 
        result1="$(( (a * i + b) % m ))"
        ;;
      0)
        result1="$(( (( i - b ) *  mmi ) % m ))"
        ;;
    esac
    result+="${Alpha_ar[$result1]}"
    #printf "%s" "$result"
    chain="${chain:1}"
  done
  printf "%s\n" "$result"
}
main () {
    IFS2="$IFS"
    IFS="$Newline"
    declare TEMP0=""
    declare -A Opts=( ) # Stores options and their values
    Args="" # This string is "$*" without options/values      
    declare -a Input=( )
    declare Input2=""
    test_params "$@"
    case "$?" in
      '1'|'2')  # Note : Args are passed unquoted
                #      ( Otherwise only $1 exists!)
                co_Primes $Args \
                  || { echo "a and m must be coprime."
                       exit 11
                     }
                mk_Code $Args
                ;;

            *)  printf2 "Invalid input occurred.."
                exit 1
                ;;
    esac
    exit 0
}
main "$@"

# DR - Ascension 2025 plus: 075 days...
