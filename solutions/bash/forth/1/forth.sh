#!/usr/bin/env bash
#
# Maths : Nope
#
#    ( *VERY* painful exercism ! 
#      Dont bash very well though.. (note)
#      But Worth it ?! )
#
# Note: This behavior reminds me the 
#         'reverse-polish calculator' : $ dc
#       I should have used 'dc'..
#        ie: dc<<<"7 2 * 11 + p" 
#                         ('p' is for print)
#        ie: dc -e "7 d 9 r * 11 + - f"
#            ('d' is dup 'r' is swap,
#             'f' prints the -main!- stack)
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
Ifs=$'\n\t '

store_Input () {
  # No regression : keeping previous forms.
  # Reading from '<<< "Ansi-C string", or a File
  # or Classical arguments
  printf2 "\$1 is :==%s==\n" "$1"
  printf2 "\$* is :==%s==\n" "$*"

  # Enabled 'Input_From_File' mode
  #   (assuming each line is a set of args for $0
  #    this may mess up multiple lines input scripts)
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

  # Populates Input[] global array
  #  and do some pre-stuff (if none ':')
  #  on inputs.. 
  #  (wether they're 'from files' or not)
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
  
  # Last value(s) is(are) empty line(s)  => to remove
  printf2 "unset Input[%i] ==%s==\n" "$i" "${Input[i]}"
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

  # Multiple lines to manage > Comments.. ########
  #
  # Always true with herescripts inputs (<< INPUT)
  #if [[ Input_From_File -eq 1 ]]
  #then
  #  for i in "${!Input[@]}"
  #  do
  #    "./$0" "${Input[i]}"
  #    [[ "$?" -ne 0 ]] && exit 99
  #  done
  #fi
  
  #if [[ Input_From_File -eq 1 ]]
  #then
  #  printf2 "end of file process" && exit 0
  #fi
  ################################################

  # Standard value
  IFS="$Ifs"

  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
}

test_regex () {
# Conforms with @tests input patterns 
#  (or not)
#        
REGEX_PARAM=\
'[[:digit:]]\+'
REGEX_PARAMS=\
"^$REGEX_PARAM$"

REGEX_PARAM_WRD=\
' \+| -| \*| /| dup| drop| swap| over'
REGEX_PARAM_DEF=\
'^: [[:print:]]+( [[:print:]]+)*'
REGEX_PARAM1=\
'-?[[:digit:]]+'
REGEX_PARAM2=\
"^$REGEX_PARAM1( $REGEX_PARAM1)*$" 

  printf2 "$Input2" \
      | grep -q "$REGEX_PARAMS" \
     && printf2 'GREP QUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual ! (grep)'

  [[ "$Input2" =~ $REGEX_PARAM2 ]] \
     && printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !' \
     || printf2 'RegExpr Wrong as usual !  (=~) '

  [[ "$Input2" =~ $REGEX_PARAM_DEF ]] \
     && printf2 'UNARY OPERATOR UNQUOTED 22 RegExpr Positive !' \
     || printf2 'RegExpr 22 Wrong as usual !  (=~) '

# For using REGEX var
IFS='|'
for i in ${REGEX_PARAM_WRD//\\} 
do
    [ "$i" == ' *' ] && i=' \*'
    Dict["$i"]="$i"
done

   printf2 "Dict@ :" "${Dict[@]}"
   printf2 "Dict! :" "${!Dict[@]}"
}
IFS=$' '
# End using REGEX var

exec_Cmd () {

  cmd="$1"

  # [[:lower:]]
  cmd="${cmd@L}"

  stk_sz="$(( ${#Stack[@]} - 1 ))"

  printf2 "executing :" "$cmd"
  case " $cmd" in
  ' +'|' -'|' \*'|' /'|' swap'|' over')
      
      if [[ "${#Stack[@]}" -eq 0 ]]
      then
        echo "empty stack" && exit 1
      else
        if [[ "${#Stack[@]}" -eq 1 ]]
        then
          echo "only one value on the stack" \
            && exit 1
        fi
      fi

      case " $cmd" in
        ' +')
              (( Stack[stk_sz - 1]+=Stack[stk_sz] ))
              unset Stack[stk_sz]
              ;;
        ' -')
              (( Stack[stk_sz - 1]-=Stack[stk_sz] ))
              unset Stack[stk_sz]
              ;;
        ' \*')
              (( Stack[stk_sz - 1]*=Stack[stk_sz] ))
              unset Stack[stk_sz]
              ;;
        ' /')
              [[ "${Stack[stk_sz]}" -eq 0 ]] \
                && echo "divide by zero"        \
                && exit 3
              (( Stack[stk_sz - 1]/=Stack[stk_sz] ))
              unset Stack[stk_sz]
              ;;
     ' swap')
              tmp0="${Stack[stk_sz]}"
              Stack[stk_sz]="${Stack[stk_sz - 1]}"
              Stack[stk_sz - 1]="$tmp0"
              ;;
     ' over')
              Stack[stk_sz + 1]="${Stack[stk_sz - 1]}"
              ;;
           *)
              echo "error case2"
              ;;
      esac
      ;;

  ' dup'|' drop')
      
      if [[ "${#Stack[@]}" -eq 0 ]]
      then
        echo "empty stack" && exit 1
      fi

      case " $cmd" in
        ' drop')
            unset Stack[stk_sz]
          ;;
        ' dup')
            Stack[stk_sz + 1]="${Stack[stk_sz]}"
          ;;
             *)
            printf2 "error case3"
          ;;
      esac
      ;;

      " *[0-9]*")
          Stack[stk_sz]="$cmd"
        ;;
      " ")
          : 
        ;;
      *)
        printf2 "undefined cmd:" "$cmd"
        echo "undefined operation" && exit 1
        printf2 "error case1 --%s--\n" "${Stack[@]}"
        printf2 "error case1"
        ;;
  esac
  printf2 "Stack@ end run_Cmd : --%s--\n" "${Stack[@]}"
}

run_Interpreter () {

    IFS=$' '
    i=0
    REGEX_END='^-?[[:digit:]]+( -?[[:digit:]])* ?$'
    REGEX_DIG='^-?[[:digit:]]+'
    REGEX_DIG_ALL="^$REGEX_DIG( $REGEX_DIG)*$"
    Command="$*"
    Command2="$*"
            
    printf2 "C62 --%s--\n" "$Command2"

      while [[ "$Command2" =~ $REGEX_DIG ]]
      do
          Stack[i]="${Command2/ *}"
            printf2 "C52 --%s--\n" "$Command2"
            printf2 "Stack[@] --%s--\n" "${Stack[@]}"
          Tmp="$Command2"
          Command2="${Command2#* }"
          [ "$Command2" == "$Tmp" ] && break
            printf2 "C42 --%s--\n" "$Command2"
          [[ "$Command2" =~ $REGEX_DIG_ALL ]] \
          && finished=1                       \
          && ((i++))                          \
          &&  Stack[i]="${Command2/* }"       \
          && break
          ((i++))
      done

      printf2 "Stack@ -- : --%s--\n" "${Stack[@]}" 
      printf2 "C2- --%s--\n" "$Command2"

      if [[ "$finished" -eq 1 ]]
      then
          printf2 "Stack@ -  --%s--\n" "${Stack[@]}"
          printf2 "C2- --%s--\n" "$Command2"
          return 0
      fi

      exec_Cmd "${Command2/ *}"

      while [[ "$Command2" =~ ' ' ]]
      do
         Command2="${Command2#* }"
         if [[ "$Command2" =~ $REGEX_DIG ]]
         then
           printf2 "C72 -%s- -%s-\n" "${Stack[@]}" \
                                     "$Command2"
            run_Interpreter "${Stack[@]}" "${Command2}"
            Command2="${Command2/ [0-9]*}"

            printf2 "C12 --%s--\n" "$Command2"
            return $?
         fi
            printf2 "C22 --%s--\n" "$Command2"
            exec_Cmd "${Command2/ *}"
      done

      printf2 "Stack@ : --%s--\n" "${Stack[@]}"
            printf2 "C32 --%s--\n" "$Command2"
      printf2 "Command2 : --%s--\n" "$Command2"
}

dict_Translate () {

  ind="$1"
  if [[ "$ind" -ne -1 ]]
  then
    printf2 "Input@ :" "${Input[@]}"
    printf2 "Input1 :" "${Input["$1"]}"
    imp2=" ${Input["$1"]@L}"
  else
    declare -n def="$2"
    imp2=" ${def@L}"
  fi


  for j in "${!Dict[@]}"
  do
    [ "$j" == ' *' ] && j=' \*'
    printf2 "!Dict :" "$j"
    imp2="${imp2//$j/${Dict[$j]}}"
    printf2 "imp2 i dicti: -%s- -%s- -%s-\n" \
                        "$imp2" "$j" "${Dict[$j]}"
    printf2 "Input[1]:" "${Input[$1]}"
  done
  
  if [[ "$ind" -ne -1 ]]
  then
    Input["$1"]="$imp2"
  else
    def="$imp2"
  fi
}

set_Definition () {
   def="$1"
   def_word="${def/ *}"
   def_val="${def#* }"
   printf2 "set_Definition :" "$1" 
   printf2 "Definition word  :" "$def_word" 
   printf2 "Definition value :" "$def_val" 
      
   dict_Translate "-1" "def_val"

   unset Dict["$def_word"]
   printf2 "Dict@ :" "${Dict[@]}"
   printf2 "Dict! :" "${!Dict[@]}"

   if [[ -n "${Dict["$def_val"]}" ]]
   then
       Dict[" $def_word"]=" ${Dict["$def_val"]}"
   else
       Dict[" $def_word"]=" $def_val"
   fi
   printf2 "Dict@ :" "${Dict[@]}"
   printf2 "Dict! :" "${!Dict[@]}"
}

test_params () {

  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)
  i=0
  REGEX_DIG_DEF=": $REGEX_PARAM1"
  REGEX_SCO_DEF=';$'

  # Useless here..
  #if [[ ! "$Input2" =~ $REGEX_PARAM2 ]]
  #then
      IFS=$' '
        #echo "def: -$def-"
        #echo $REGEX_PARAM_DEF
      while [[ "$Input2" =~ $REGEX_PARAM_DEF ]]
      do
        def="${Input[i]@L}"
        #echo "def: -$def-"
        [[ "$def" =~ $REGEX_DIG_DEF ]] \
          && echo "illegal operation" && exit 1
        [[ ! "$def" =~ $REGEX_SCO_DEF ]] \
          && echo "macro not terminated with semicolon" \
          && exit 1
        def="${def/: }"
        def="${def/ ;}"
        [[ ! "$def" =~ ' ' ]] \
          && echo "empty macro definition" && exit 1
        set_Definition "$def"
        ((i++))
        Input2="${Input[i]}"
      done
          
comm=$(cat <<fin    
      printf2 "Input Wrong Regex"
echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
      "     or $0 [file]"$'\n'\
      "with    $0 <N> (Natural number)"
fin
)
comm=""

      #printf2 "Arguments Ko !"
      #return 1

  #else

      #printf2 "Arguments Ok !"
  #fi
      printf2 "Imput@ :" "${Input[@]}"
      printf2 "Imputi :" "${Input[i]}"
      dict_Translate "$i"

      printf2 "InputI :" "${Input[i]}"

      run_Interpreter "${Input[i]}"

      # Result is the Stack
      #
      echo "${Stack[@]}"
      return 0
}

# All is done previously..
#
mk_Forth () {
    :
}

main () {
    # Disabled (Input2 regex test wrong 
    #           when opt $2=1)
    #IFS="$Newline"
    
    declare -A Dict
    declare -a Stack 

    Args=""
    declare -a Input=( )
    declare Input2=""

    test_params "$@"

    case "$?" in
          '0')  # Note : Args are passed unquoted
                #      ( Otherwise only $1 exists! )
                mk_Forth $Args
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 155 days...
