#!/usr/bin/env bash
#
# Maths 
#    Spiral matrix of  size S
#    generate a matrix with S² elements (maxsize)
#    4 options : 
#                1. Constructivism
#                2. Storage
#                3. Both
#                4. Just do it !
#
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
shopt -s extglob
Newline=$'\n'
# Default IFS var
Ifs=$'\n\t '

store_Input () {
  # No regression : keeping previous forms.
  # Reading from '<<< "Ansi-C string", or a File
  # or Classical arguments and their options if any.
  # Todo : implies self calls for each line with args
  #        implies input types caracterisation (3)
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
      :
    else
      : 
    fi
    ((i++))
  done < <(echo "$Args")
  
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
  # Last value is an empty line  => to remove !
#if [[ "$#" != 0 ]]
#then
  while [[ "${Input[i]}" =~ "^$" ]] || \
  [ "${Input[i]}" == "" ] 
  do
      unset "Input[i]"
      ((i--))
      [[ "$i" -lt 0 ]] && break
  done
#fi

  # Debuging check
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : %s\n" "$i" "${Input[i]}"
  done

  # Always true with herescripts inputs (<< INPUT)
  if [[ Input_From_File -eq 1 ]]
  then
    for i in "${!Input[@]}"
    do
      "$0" "${Input[i]}"
    done
  fi
  
  if [[ Input_From_File -eq 1 ]]
  then
    printf2 "end of file process" && exit 0
  fi

  # Standard value
  IFS="$Ifs"

  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}

test_regex () {
# Conforms with @tests input pattern 
#        
REGEX_PARAM=\
'[[:digit:]]\+'
REGEX_PARAMS=\
"^$REGEX_PARAM$"

REGEX_PARAM1=\
'[[:digit:]]+'
REGEX_PARAM2=\
"^$REGEX_PARAM1( 1)?$" 

  printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual ! (grep)'

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
      "with    $0 <N> (Natural number)"
      return 1
  else

      printf2 "Arguments Ok !"
      return 0
  fi
}

mk_Spiral () {
  declare -i nb=1 n="$1"
  declare -i N="$((n**2))" i=1 j=1 incr=1 n1="$n"
  declare -A Matrix

  printf2 'n %s N %s nb %s\n' \
          "$n" "$N" "$nb"

  while [[ "$nb" -lt "$N" ]]
  do

    while true 
    do
      if [[ ! -n ${Matrix["${i}_${j}"]} ]]
      then
          Matrix["${i}_${j}"]="$nb"
          ((nb++))
          printf2 "W3 - i:j nb %s:%s %s\n" \
                  "$i" "$j" "$nb"
      fi
      ((i+=incr))
      [[ "$i" -gt "$n" ]] && break
    done
    ((i-=incr))

    while true 
    do
      if [[ ! -n "${Matrix["${i}_${j}"]}" ]]
      then
          Matrix["${i}_${j}"]="$nb"
          ((nb++))
          printf2 "W3 - i:j nb %s:%s %s\n" \
                  "$i" "$j" "$nb"
      fi
      ((j+=incr))
      [[ "$j" -gt "$n" ]] && break
    done
    ((j-=incr))

    ((incr*=-1))
    
    while true 
    do
      if [[ ! -n "${Matrix["${i}_${j}"]}" ]]
      then
          Matrix["${i}_${j}"]="$nb"
          ((nb++))
          printf2 "W3 - i:j nb %s:%s %s\n" \
                  "$i" "$j" "$nb"
      fi
      ((i+=incr))
      [[ "$i" -le "$((n1 - n))" ]] && break
    done
    ((i-=incr))

    ((n--))

    while true 
    do
      if [[ ! -n "${Matrix["${i}_${j}"]}" ]]
      then
          Matrix["${i}_${j}"]="$nb"
          ((nb++))
          printf2 "W3 - i:j nb %s:%s %s\n" \
                  "$i" "$j" "$nb"
      fi
      ((j+=incr))
      [[ "$j" -le "$((n1 - n))" ]] && break
    done
    ((j-=incr))

    ((incr*=-1))
    
  done

  if [[ "$((n1 % 2))" -eq 1 ]]
  then
    # For some reason missing last
    #  when odds..
    Matrix["${j}_${j}"]="$((n1**2))"
  fi

  for i in $(seq $n1)
  do
    Line=""
    for j in $(seq $n1)
    do
      # Option makes better looking 
      # results.. (but wont do @tests)
      # try '$0 16 1' !
      normalize=1
      [[ "$2" -eq 1 ]] && normalize="${#N}"
      Line+="$(printf "% ${normalize}s:" \
        "${Matrix["${j}_${i}"]}")"
    done
      Line="${Line%:}"
      printf '%s\n' "${Line//:/ }"
  done

}

main () {
    # Disabled (Input2 regex test wrong 
    #           when opt $2=1)
    #IFS="$Newline"

    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
          '0')  # Note : Args are passed unquoted
                #      ( Otherwise only $1 exists! )
                mk_Spiral $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 153 days...
