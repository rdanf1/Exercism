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
shopt -s extglob
Newline=$'\n'

declare -a Alpha_ar=( {a..z} )
declare -A Alpha_Aar=( )
declare -i j=0
declare -a	Nb_ar=(  $' _ \n| |\n|_|\n   ' \
                     $'   \n  |\n  |\n   ' \
                     $' _ \n _|\n|_ \n   ' \
                     $' _ \n _|\n _|\n   ' \
                     $'   \n|_|\n  |\n   ' \
                     $' _ \n|_ \n _|\n   ' \
                     $' _ \n|_ \n|_|\n   ' \
                     $' _ \n  |\n  |\n   ' \
                     $' _ \n|_|\n|_|\n   ' \
                     $' _ \n|_|\n _|\n   '
             )

for i in {0..9}
do
    : 
    #printf2 "Nb_ar %i : \n%s\n" "$i" "${Nb_ar[i]}"
done


All_Nb=$(cat << INPUT
    _  _     _  _  _  _  _  _ 
  | _| _||_||_ |_   ||_||_|| |
  ||_  _|  | _||_|  ||_| _||_|
                              
INPUT
)

#printf2 "All_Nb :\n%s\n" "$All_Nb"

#echo "$All_Nb" | cut -c 1-3
#echo "$All_Nb" | cut -c 4-6
All_Nb="$(echo "$All_Nb" | cut -c 4- )"
#echo "$All_Nb"3



store_Input () {
  # No regression : keeping previous forms.
  # Reading from '<<< "Ansi-C string", or a File
  # or Classical arguments and their options if any.
  # Todo : implies self calls for each line with args
  #        implies input types caracterisation (3)
  printf2 "\$1 is :==\n%s==\n" "$1"
  printf2 "\$* is :==\n%s==\n" "$*"

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
  
  # Last value is an empty line  => to remove !
  while [[ "${Input[i]}" =~ "^$" ]] || \
  [ "${Input[i]}" == "" ] 
  do
      unset "Input[i]" && \
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
      ((i--))
      [[ "$i" -lt 0 ]] && break
  done

  # Debuging check
  for i in "${!Input[@]}"
  do
    printf2 "Input[%i] : ==%s==\n" "$i" "${Input[i]}"
  done

  j=0
  # Always true with herescripts inputs (<< INPUT)
  if [[ Input_From_File -eq 1 ]]
  then
    for i in "${!Input[@]}"
    do
      # ----------->> Must append LF manually
      Input_4l[j]+="${Input[i]}"$'\n'
      [[ "$(((i + 1) % 4))" -eq 0 ]] && ((j++))
 # hs always void..
 #       && echo "Input_4l $j : ${Input_4l[j]}" && "$0" "${Input_4l[j]}"
    done
  fi
  
  for j in "${!Input_4l[@]}"
  do
    printf2 "\nInput_4l %i : ==\n%s==\n" "$j" "${Input_4l[j]}"

    "./$0" "${Input_4l[j]}"
    Return="$?"

    if [[ "$((j+1))" -ne "${#Input_4l[@]}" ]]
    then
        printf ','
    else
        printf '\n'
    fi

  done

  if [[ Input_From_File -eq 1 ]]
  then
    printf2 "\n%s\n" "end of file process" && exit "$Return" 
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
REGEX_PARAM1=\
' |\||_|$'
REGEX_PARAM2=\
"^($REGEX_PARAM1)*$" 

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
      "with    $0 <rollings> (1 to 20-22 max)"
      return 1
  else
      [[ "$Input2" == "" ]] && echo ""

      [[ "$(( ${#Input[@]} % 4 ))" -ne 0 ]] \
      && echo "Number of input lines is not a multiple of four" \
      && exit 2

      for i in "${!Input[@]}"
      do
        [[ "$(( ${#Input[i]} % 3 ))" -ne 0 ]] \
    && echo "Number of input columns is not a multiple of three" \
        && exit 3
      done



      printf2 "Arguments Ok !"
      return 0
  fi
}

mk_Sth () {

  printf2 "Making Sth.. ==\n%s==" "$1"
  input="$1"
  while [[ "${#input}" -ne 0 ]]
  do
    digit="$( echo "$input" | cut -c 1-3 )"
    printf2 "\ndigit : =\n%s=" "$digit"
  
    case "$digit" in
      "${Nb_ar[0]}") printf '0' ; ;;
      "${Nb_ar[1]}") printf '1' ; ;;
      "${Nb_ar[2]}") printf '2' ; ;;
      "${Nb_ar[3]}") printf '3' ; ;;
      "${Nb_ar[4]}") printf '4' ; ;;
      "${Nb_ar[5]}") printf '5' ; ;;
      "${Nb_ar[6]}") printf '6' ; ;;
      "${Nb_ar[7]}") printf '7' ; ;;
      "${Nb_ar[8]}") printf '8' ; ;;
      "${Nb_ar[9]}") printf '9' ; ;;
                  *) printf '?' ; ;;
    esac

    input="$(echo "$input" | cut -c 4- )"
  done
}

main () {
    IFS2="$IFS"
    IFS="$Newline"

    Args=""
    declare -a Input=( )
    declare -a Input_4l=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
          '0')  # Note : Args are passed quoted
                #      ( => only "$1" exists including LFs ! )
                mk_Sth "$Args"
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 085 days...
