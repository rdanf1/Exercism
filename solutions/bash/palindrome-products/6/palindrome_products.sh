#!/usr/bin/env bash
# Maths : enumerate pairs of numbers 
#         within a particular range without repetition :
#                             [N..M]
#       N ( N N+1 .. N+M )
#       N+1 ( N+1 .. N+M )
#       10 11 12 13 14 15 16 17 18 19 20
#       etc..
#       Time consuming with 1000-9999 is much too long..
#       ................................................
#       So :
#       getting lowest and upper values
#       and picking palindromes within this interval
#       is more efficient to find a pair in the interval 
#       that matches.. => playing with pre-constructed
#                         digits palindromes is better!
#       then find multiples of these 
#       satisfying prop. (x, y) ∈ [min-max]² and 
#                     and x * y = "palindrome nb"
#
# NB0 : Assuming input intervals are "usually" similar to :
#            [10^(n) ; 10^(n+1) - 1 ]
#
# NB1 : All palindomes numbers with pair nb of digits (P₂) 
#           are multiples of 11
#       => this simplify the search of X.Y=P₂ / X,Y ∈ [a,b]
#       for maximum pair with Y'∈ [a/11;b/11]
#                       ie    Y'∈ [91;909] instead of [1000;9999]
#       
# NB2 : Halas no such a propriety (as in NB1) exists for P₁ :
#          palindomes with odds nb of digits
#
# I) Trying to do this models with n digits :
#   a) Decremental List of Palindromes (8 digits) :
#for l in {9..1} ; do for k in {9..0} ; do for j in {9..0} ; do for i in {9..0} ; do echo ${l}${k}${j}${i}${i}${j}${k}${l} ; done ; done ; done ; done
#   b) Incremental LoP :
#for l in {1..9} ; do for k in {0..9} ; do for j in {0..9} ; do for i in {0..9} ; do echo ${l}${i}${j}${k}${k}${j}${i}${l} ; done ; done ; done ; done
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

# Is this the output scheme ?
#printf2 "9:[1, 9] [3, 3]"
#exit
# => yes !

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
      Args="$*"
    fi
  fi

  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  printf2 "Args : ==\n%s==\n" "$Args"

  i=0
  while read -r Input["i"]
  do
    if [[ Input_From_File -eq 1 ]]
    then
      "./$0" "${Input[i]}"
      Return="$?"
    else
      : 
    fi
    ((i++))
  done < <(echo "$Args")
  
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  # Last value is an empty line  => to remove !
  while [[ "${Input[i]}" =~ "^$" ]] || \
  [ "${Input[i]}" == "" ] 
  do
      unset "Input[i]"
      ((i--))
      [[ "$i" -lt 0 ]] && break
  done

  # Debuging check
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done

  if [[ Input_From_File -eq 1 ]]
  then
    printf2 "end of file process" && exit "$Return"
  fi

  IFS="$IFS2"
  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}

test_regex () {
# Conforms with @tests input pattern 
#        
REGEX_PARAM=\
'smallest|largest'
REGEX_PARAM1=\
'[[:digit:]]+'
REGEX_PARAM2=\
"^($REGEX_PARAM)( $REGEX_PARAM1)( $REGEX_PARAM1)$" 

  [[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '
}

test_params () {

  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)


  if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  then

      [[ ! "$Input2" =~ $REGEX_PARAM ]] \
      && echo "first arg should be 'smallest' or 'largest'" \
      && exit 2
             
      printf2 "Input Wrong Regex"
  echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
        "     or $0 [file]"$'\n'\
        "with    $0 <smallest/largest> <a b> (range)"
        return 1
    else

        [[ "$2" -gt "$3" ]] && echo "min must be <= max" \
        && exit 1


        printf2 "Arguments Ok !"
        return 0
    fi
  }


  Find_pair () {
        
      x="$3"
      # Set to 0 for "All" results
      printf2 "x :" "$x"

      if [ "$4" == "D" ]
      then
          [[ "$x" -lt "$smallest" ]] && printf2 "x too small" \
            && return 1 
          #[[ "$1" -lt 1000 ]] && decr=2 || decr=20
          decr=1
          Start="$1"
          # Fails ..
          #End="$(($2 / 2 ))"
#  ( might miss some solution(s) though @tests are ok.. )
          #End="$(($2/2 + $2/3 ))"
          # Exhaustive in range sol = Ok !
          End="$2"
      else
          [[ "$x" -gt "$biggest" ]] && printf2 "x too big"
          #[[ "$2" -le 999 ]] && decr=-2 || decr=-200
          decr=-1
          Start="$2"
          End="$1"
      fi

      local result=""

      for z in $(seq "$Start" "$decr" "$End")
      do

        #printf2 "z :" "$z"

        if [[ "$((x % z))" -eq 0 ]]
        then
          a="$((x / z))"

          #[[ "$a" -ne "$z" ]] && \
          if   [[ "$a" -lt "$2" ]] && \
               [[ "$a" -gt "$1" ]] 
          then
            if [[ "$a" -lt "$z" ]]
            then
              # String Concat & printf "..\n" is Ko !
              #  => Appending $'\n' manually
              result+="$(printf "%s:[%s, %s]" "$x" "$a" "$z")"\
$'\n'
            else 
              result+="$(printf "%s:[%s, %s]" "$x" "$z" "$a")"\
$'\n'
            fi
            # Comment for All N digits results
            #   with reduced 'End' limit (<> $2)..
            [[ "$single" -eq 1 ]] && break
          fi
        fi
      done
      # Must remove blanks lines..
      #
      [ "$result" != "" ] && echo "$result" | sed '/^$/d' | sort | uniq && [[ "$single" -eq 1 ]] && exit 0
  }

  srch_Small () {

    printf2 "Making Small.."
    biggest="$(( $2 * ($2 - 1) ))"
    max_dig="${#biggest}"

    smallest="$(( $1 * ($1 + 1) ))"
    min_dig="${#smallest}"
    printf2 "smallest :" "$smallest"
    printf2 "short digits:" "$min_dig"

    #printf2 "biggest :" "$biggest"
    #printf2 "big digits:" "$max_dig"


    # Palindrome digits (max 10) 
    declare h i j k l
      
    # Purpose : Faster result(s) !
    if [[ "$max_dig" -ge 6 ]]
    then
      l_vals="$(seq ${biggest:0:1})"
      k_vals="$(seq 0 ${biggest:1:1})"
      j_vals="$(seq 0 ${biggest:2:1})"
      i_vals="$(seq 0 ${biggest:3:1})"
    fi

case "$min_dig" in

  10 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do for h in {0..9} ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${h}${h}${i}${j}${k}${l}" "D" ; done ; done ; done ; done ; done
      ;;
  9 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do for h in {0..9} ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${h}${i}${j}${k}${l}" "D" ; done ; done ; done ; done ; done
       ;;
  8 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${i}${j}${k}${l}" "D" ; done ; done ; done ; done
       ;;
  7 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${j}${k}${l}" "D" ; done ; done ; done ; done 
       ;;
  6 )
for l in  $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${j}${k}${l}" "D" ; done ; done ; done 
       ;;
  5 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${k}${l}" "D" ; done ; done ; done 
       ;;
  4 )
for l in $(seq 9) ; do for k in $(seq 0 9) ; do Find_pair "D" "$1" "$2" "${l}${k}${k}${l}" ; done ; done
       ;;
  3 )
for l in $(seq 9) ; do for k in $(seq 0 9) ; do Find_pair "$1" "$2" "${l}${k}${l}" "D" ; done ; done 
       ;;
  2 )
for l in $(seq 9) ; do for k in $(seq 0 9) ; do Find_pair "$1" "$2" "${l}${l}" "D" ; done ; done 
       ;;
  * )
      printf2 "Trivial case 1"
      echo "1:[1, 1]"

   esac
}

  srch_Big () {

    printf2 "Making Small.."
    biggest="$(( $2 * ($2 - 1) ))"
    max_dig="${#biggest}"

    smallest="$(( $1 * ($1 + 1) ))"
    min_dig="${#smallest}"
    printf2 "smallest :" "$smallest"
    printf2 "short digits:" "$min_dig"

    printf2 "biggest :" "$biggest"
    printf2 "big digits:" "$max_dig"


    # Palindrome digits (max 10) 
    declare h i j k l
    
    # Purpose : Faster result(s) !
    if [[ "$max_dig" -ge 6 ]]
    then
      l_vals="$(seq ${biggest:0:1} -1 1)"
      k_vals="$(seq ${biggest:1:1} -1 0)"
      j_vals="$(seq ${biggest:2:1} -1 0)"
      i_vals="$(seq ${biggest:3:1} -1 0)"
    fi

case "$max_dig" in

  10 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do for h in {9..0} ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${h}${h}${i}${j}${k}${l}" "I" ; done ; done ; done ; done ; done
      ;;
  9 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do for h in {9..0} ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${h}${i}${j}${k}${l}" "I" ; done ; done ; done ; done ; done
      ;;
  8 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals  ; do for i in $i_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${i}${j}${k}${l}" "I" ; done ; done ; done ; done
      ;;
  7 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do for i in $i_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${i}${j}${k}${l}" "I" ; done ; done ; done ; done
       ;;
  6 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${j}${k}${l}" "I" ; done ; done ; done
       ;;
  5 )
for l in $l_vals ; do for k in $k_vals ; do for j in $j_vals ; do Find_pair "$1" "$2" "${l}${k}${j}${k}${l}" "I" ; done ; done ; done
       ;;
  4 )
for l in {9..1} ; do for k in {9..0} ; do Find_pair "$1" "$2" "${l}${k}${k}${l}" "I" ; done ; done
       ;;
  3 )
for l in {9..1} ; do for k in {9..0} ; do Find_pair "$1" "$2" "${l}${k}${l}" "I" ; done ; done
       ;;
  2 )
for l in {9..1} ; do Find_pair "$1" "$2" "${l}${l}" "I" ; done
      printf2 "Trivial case 2"
      echo $'9:[1, 9]\n[3, 3]'
       ;;
  * )
     echo "Largest Oops !"

   esac
}

mk_Sth () {

  # Set to 0 for "All" results
  declare -i single=1

  case "$1" in
    'smallest')
       srch_Small "$2" "$3" 
      ;;
     'largest') 
       srch_Big "$2" "$3" 
      ;;
  esac
}

main () {
    IFS2="$IFS"
    IFS="$Newline"

    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
          '0')  # Note : Args are passed unquoted
                #      ( Otherwise only $1 exists! )
                mk_Sth $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 133 days...
