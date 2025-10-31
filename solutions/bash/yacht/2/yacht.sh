#!/usr/bin/env bash
#
# Maths : Nope
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
#Newline=$'\n'
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

REGEX_BET=\
'(yacht|ones|twos|fours|threes|fives|sixes'\
'|full house|four of a kind|little straight'\
'|big straight|choice)'
REGEX_PARAM1=\
'[1-6]'
REGEX_PARAM2=\
"^$REGEX_BET( $REGEX_PARAM1){5}$" 

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
  test_regex      # Uses '$Input2' (no $Args)

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

vars_Regex () {

REGEX_YACHT=\
'^(1 1 1 1 1|2 2 2 2 2|3 3 3 3 3'\
'|4 4 4 4 4|5 5 5 5 5|6 6 6 6 6)$'

REGEX_FOURS=\
'(1 1 1 1|2 2 2 2|3 3 3 3|4 4 4 4'\
'|5 5 5 5|6 6 6 6)'

REGEX_THREES=\
'(1 1 1|2 2 2|3 3 3|4 4 4|5 5 5|6 6 6)'

REGEX_LTL_STR=\
'1 2 3 4 5'

REGEX_BIG_STR=\
'2 3 4 5 6'
}

mk_Yacht () {

vars_Regex
Bet="$1"
printf2 "Bet :" "$Bet"
shift

Dices="$*"
printf2 "Dices :" "$Dices"

IFS=' '
Dices="$(echo "${Dices// /$'\n'}" | sort -n)"
Dices="${Dices//$'\n'/ }"
printf2 "Dices :" "$Dices"
IFS=$'\n\t '

result=0

case "$Bet" in
  'yacht')
         if [[ "$Dices" =~ $REGEX_YACHT ]]
         then
           echo 50
         else
           echo 0
         fi
      ;;
  'ones')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 1 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'twos')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 2 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'threes')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 3 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'fours')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 4 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'fives')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 5 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'sixes')
          for i in $(echo ${Dices// /$'\n'})
          do
            [[ "$i" -eq 6 ]] && ((result+=i))
          done
          echo "$result"
      ;;
  'full house')
         prev=0
         sum=0
         count=1
         if [[ "$Dices" =~ $REGEX_THREES ]]
         then
           for i in $(echo ${Dices// /$'\n'})
           do
             ((sum+=i))
             if [[ "$i" -eq "$prev" ]]
             then
               ((count++))
               if [[ "$count" -eq 2 ]]
               then
                 ((result-=1))
               fi
             else
               if [[ "$count" -eq 3 ]]
               then
                 count=1
               else
                 if [[ "$count" -eq 2 ]]
                 then
                   ((result-=1))
                 fi
               fi 
             fi

             prev="$i"
           done
           if [[ $result -eq -2 ]]
           then
                echo "$sum"
            else
                echo 0
           fi
         else
           printf2 "no threes!"
           echo 0
         fi
      ;;
  'four of a kind') 
         if [[ "$Dices" =~ $REGEX_FOURS ]]
         then
           for i in $(echo ${Dices// /$'\n'})
           do
             [[ "$i" -eq "$prev" ]] \
               && ((result+=i))
             prev="$i"
           done
           [[ ! "$Dices" =~ $REGEX_YACHT ]] \
             && ((result+=( result / 3) ))
             echo "$result"
         else
           echo 0
         fi
      ;;
  'little straight')
         if [[ "$Dices" =~ $REGEX_LTL_STR ]]
         then
           echo 30
         else
           echo 0
         fi
      ;;
  'big straight')
         if [[ "$Dices" =~ $REGEX_BIG_STR ]]
         then
           echo 30
         else
           echo 0
         fi
      ;;
  'choice')
         for i in $(echo ${Dices// /$'\n'})
         do
           ((result+=i))
         done
         echo "$result"
      ;;
        *)
         echo "not a Yatch bet"
      ;;
esac
return 0
}


main () {

    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
          '0')  
                mk_Yacht "$@"
                ;;
            *)  
                printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 153 days...
