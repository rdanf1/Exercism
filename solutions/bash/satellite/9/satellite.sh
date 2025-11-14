#!/usr/bin/env bash
#

# To see..
examples=$(cat <<fin
              pre-order
            ( a i x f r )              could be...
  a      ---> a                            a
 / \                                        \
i   x    -------> i > x                      i
   / \                                        \
  f   r  -------------> f > r                  x     in-order
                                      in-order  \  << could be 
                                   ( i a f x r ) f   the same
  a                           i   <- i            \  as pre-order
 / \                           \                   r
i   x    --> turn 45º :     f   a <---- a < f
   / \                       \ /
  f   r                       x   <----------- x
                             /
                            r     <-------------- r
fin
)
echo "${examples:-1}" >/dev/null
# Seen (thx to example) :
#
# I) Practically aim levels : 
#       horizontals  (pre-order) to right
#       or verticals (in-order)  to bottom from left
# will do it !
#                             
# II) Pb is to solve recursively (regular sol though..) :
#          a
#    1.   / \  : B, C, subtrees (pre-order)
#        B   C
#
#          B
#    2.   / \  : B, C, subtrees (in-order)
#        a   C
#
# III) Plus on binary trees by definition :
#
#     - 1 root has 2 leafs max, 0 min
#     - => horizontal level n L(n)  has 2*Card[L(n-1)]
#                     leafs max / Line(i) = {0,1,2,4,8,..,2*(n-1)}
#                     leafs min / Line(i) = {0,1,1,1,1,..,(n-1)}
#
# a   - Trivial case (RT) :
#  \      'pre-order' is equal to 'in-order' means
#   i     single right handed leafs (a i ..)
#    \
#     ..
#
#     - Trivial case (LT) :                          a
#         'pre-order' is opposite 'in-order' means  /
#         single left  handed leafs (a i ..)       i
#                                   (.. i a)      /
#                                               ..
#
#     - 1st Item in in-order is last left value (llv) of the tree
#     - 1st Item in pre-order is root value (r) of the tree
#     
#     - if (llv) = (r) there is no main left subtree
#
#     - ..
#
# IV) Algorithm : Construct binary tree (BT) 
#                 parsing pre-order elements
#                 and positionning into previous elements
#                 with in-order sequence check :
#
#    ie : (r,a,c,b,d) pre-order 
#         (b,a,r,c,d) in-order 
#
#             0. r
#                                           r  
#             1. a is left of r in-order : /   
#                                         a 
#                                             r
#                                            / \
#             2. c is right of r in-order : a   c  
#                                                  r
#                                                 / \
#                                                a   c
#                                               /
#             3. b is left of a in-order :     b    
#                                                   r
#                                                  / \
#                                                 a   c
#             4. d is right of c in in-order     /     \
#                                               b       d
#
# V) Datas : json struct.
#       orphans (b/d) => b: {"v": "b", "l": {}, "r": {}
#
#    ( 'jq' tool : yes, installed on exercism ! )
#

#exit

# DR - Signature :
Ascension_2025="\
(60*60*24*365*56-60*60*24*203-2*60*60)\
"
date_DR="$(( $(date +%s --date="now") \
             - Ascension_2025 ))"
tail -n 1 "$0" | grep -q "^$" \
  && date '+# DR - Ascension 2025 plus: %j days...' \
   --date="@$((date_DR))" >> "$0"

# Debug mode printf
DEBUG=0 
PRINTF='printf'

printf2 () {
  if [[ "$DEBUG" -gt "0" ]]
  then
    if [[ "$1" =~ '%' ]]
    then
        # exercism's check bot.. proof !!!
        "$PRINTF" "$@"
    else  
        # regular syntax is bot ok !
        printf '%s\n' "$*" 
    fi
  fi
  return 0
}

# Begin
#

# Sepatator is Newline
# For Input array values 
#   (1 for each argument)
IFS=$'\n'

# Default IFS var
#  for Input2 regular 
#  'flat' string of args
#Ifs=$'\n\t '

quot () {
  printf $'"%s"' "$1"
}

mk_orphan_JSON () {

  printf '{"v": ' \
    && quot "$1" && printf ',\n "l": {},\n "r": {}\n}\n'
}


store_Input () {

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
      { Args=$(cat "$*" 2>/dev/null) && \
        Input_From_File=1 ;} || \
        { echo "Input File issue.." >&2
          exit 33
        }
    else
      Args="$*"
    fi
  fi

  printf2 "Args1 EOL cut : ==%s==\n" "${Args//$'\n'*/}"
  printf2 "Args : ==>%s<==\n" "$Args"

  # Fills Input array
  # and may do some pre-input
  # depending of its type
  #
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
  #
  # Last value is an empty line  => to remove !
  #
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

  # Always true with herescripts inputs (<< INPUT)
  if [[ Input_From_File -eq 1 ]]
  then
    for i in "${!Input[@]}"
    do
      "$0" "${Input[i]}"
      ret="$?"
    done
  fi
  
  if [[ Input_From_File -eq 1 ]]
  then
    printf2 "end of file process" && exit "$ret"
  fi

  # Standard value
  IFS=' '

  # "Flat" input for passing regex 
  #       [@] or [*] preserves EOL
  Input2="${Input[*]}"
  printf2 "Input2 : ==%s==\n" "$Input2"
  IFS=$'\n\t '
}

test_regex () {
# Conforms with @tests input patterns
#        
REGEX_PARAM1=\
'[[:alnum:]]'
REGEX_PARAMS=\
"^($REGEX_PARAM1( $REGEX_PARAM1)*)*$" 

if [[ "$Input2" =~ $REGEX_PARAMS ]]
then
      printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !'
else
      printf2 'RegExpr Wrong as usual !  (=~) '
fi
}

test_params () {

  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)

  if [[ ! "$Input2" =~ $REGEX_PARAMS ]]
  then

      printf2 "Input Wrong Regex"
echo " Usage : $0 [<<< $'Ansi-C string' or \"\$str\"]"$'\n'\
      "     or $0 [file]"$'\n'\
      "with    $0 <N> (Natural number)"
      return 1
  else
      # 2 args or exit
      #
      [[ "$#" -ne 2 ]] && printf "\n2 args needed :\
        \n  (\"<pre-order str>\" \"<in-order str>\n)\n" \
        && exit 1

      if [ "$1" == "" ] && [ "$2" == "" ]
      then
        echo "{}"
        exit 0
      fi

      shopt -s extglob

      reg='^[[:alnum:]]$'
      if [ "$1" == "$2" ] && [[ "$1" =~ $reg ]]
      then
        result_JSON="$(mk_orphan_JSON "$1")"

        printf2 "result_JSON :" "$result_JSON"

        result_JSON=\
"${result_JSON// \"l\": \{\},$'\n' \"r\": \{\}$'\n'\}/ \"l\": \{\}, \"r\": \{\}\}}"
        result_JSON=\
"${result_JSON//\{\"v\": \"*([[:alnum:]])\",$'\n' \"l\": \{\}, \"r\": \{\}\}/\{\"v\": \""${BASH_REMATCH[0]}"\", \"l\": \{\}, \"r\": \{\}\}}"
        
if [[ $DEBUG -gt 1 ]]
then
        IFS=$'\n'
        while read -r line 
        do
          echo "-$line-"
        done < <(echo "$result_JSON")
fi

        # testing if yq/jq is present up there
        #
        result_JSON="$(jq -c . <<< "$result_JSON")"
        result_JSON="${result_JSON//:/: }"
        result_JSON="${result_JSON//,/, }"

        echo "$result_JSON"
        # to see what's the heck happening in failed @test
        #   => exercism's jq dont take --arg opt as mine !!
        #echo "result5 :"
        #echo "$(./$0 "a i x f r" "i a f x r")"
        #echo "end result5 :"

        exit 0
      fi

      pre_sort="$(echo "$1" | sed 's/. /&\n/g' \
                            | sort | sed 's/.\n/& /g')"
      in_sort="$(echo "$2" | sed 's/. /&\n/g' | sort \
                           | sort | sed 's/.\n/& /g')"
      printf2 "--%s-- , --%s--\n" \
            "${in_sort// }" "${pre_sort// }"

      if [[ "${#pre_sort}" -ne "${#in_sort}" ]]
      then
        echo "traversals must have the same length"
        exit 2
      fi
      

      if [ "${pre_sort// }" != "${in_sort// }" ]
      then
        echo "traversals must have the same elements" 
        exit 2
      fi

      j="${pre_sort/ $'\n'*}"
      #echo "j: -$j-"
      #echo "pre_sort: -$pre_sort-"
      for i in $pre_sort
      do
        if [ "$i" == "$prev" ] \
          && [[ -n "$prev" ]]
        then
          echo "traversals must contain unique elements"
          exit 3
        fi
        prev="$i"
      done

      printf2 "Arguments Ok !"
      return 0
  fi
}

# Returns 1 if $1 is left side of $2
# Returns 0 otherwise ( $1 right side of $2 )
#
pos_in_LR () {

  [ "$1" == "" ] && exit 2 

  case "$2" in
    'l')
    reg="$1"'[[:space:]]+[[:alnum:]]+'
    ;;
    *)
    reg='[[:alnum:]]+[[:space:]]+'"$1"
    ;;
  esac

  if [[ "$in_Order" =~ $reg ]]
  then

    if [ "$2" == "l" ]
    then
      res="${in_Order##*"$1" }"
      echo "${res/ *}"
    else
      res="${in_Order%% "$1"*}"
      echo "${res/* }"
    fi

    return 0
  fi

  return 1
}

if [[ "$DEBUG" -gt 1 ]]
then
  in_Order="b a c"

  pos_in_LR "b" 'l'
  echo "b is left side of ? $?"
  pos_in_LR "a" 'l'
  echo "a is left side of ? $?"
  pos_in_LR "c" 'l'
  echo "c is left side of ? $?"

  pos_in_LR "b" 'r'
  echo "b is right side of ? $?"
  pos_in_LR "a" 'r'
  echo "a is right side of ? $?"
  pos_in_LR "c" 'r'
  echo "c is right side of ? $?"
fi

# $2 is json, $1 element to find
#
find_path_JSON () {
  
  declare -n path1="$2"
  # Dealing with spaces
  IFS=$'\n'

  found=0
  spaces2='                                         \
                                                    \
                                                    \
                                                    '
  path_v=""

  reg=\""$1"\"

  shift; shift

  while read -r i
  do 
    printf2 "i : -%s-" "$i"
    [[ "$i" =~ $reg ]] && found=1
    [[ "$found" -ne 1 ]] && continue

    spaces="${i// [[:alnum:]]*}"" "
    spaces="${i// [[:punct:]]*}"" "
    printf2 "spaces: -%s-" "$spaces"
    printf2 "spaces2: -%s-" "$spaces2"
    [[ "${#spaces}" -gt "${#spaces2}" ]] \
      && break
    spaces2="$spaces"
  
    reg2=$': {$'
    if [[ "$i" =~ $reg2 ]]
    then
      # Save (r/l)
      path_v+="$(echo "$i" | sed 's/^ *//g' \
                           | cut -d'"' -f 2)"
      printf2 "path_v :" "    $path_v"
    fi

    printf2 "i:" "$i"

    printf2 "path_v :" "    $path_v"


  done < <(echo "$*" | tac)
    

  path1=$(echo "$path_v" | sed 's/./&\./g' | rev)

  [[ "${#path_v}" -eq 0 ]] && path1='.'
    
  printf2 "path1 :" "$path1"
}

#find_path_JSON "o" path "$(cat dan.json)"
#find_path_JSON "p" path  "$(cat dan.json)"
#find_path_JSON "root" path "$(cat dan.json)"
#exit

# using 'jq' utility
#  *without* useless --arg or --argjson
#            because always *wrong*..
add_Left () {
    printf2 "add_Left %s %s\n" "$1" "$2"
    result["$2-L"]="$1"
    find_path_JSON "$2" path "$result_JSON"
    printf2 "path-L :" "$path"
    printf2  "result_JSON-L-before :" "$result_JSON"

    left=\""$1"\"
    if [ "$path" == '.' ]
    then
        result_JSON="$(jq \
"add(.l.v=$left) | add(.l.l={}) | add(.l.r={})" \
                      <<<"$result_JSON")"
    else
      result_JSON="$(jq \
"add($path.l.v=$left) | add($path.l.l={}) | add($path.l.r={})" \
                      <<<"$result_JSON")"
    fi

  printf2 "result_JSON-L :" "$result_JSON"
}

add_Right () {
    printf2 "add_Right %s %s\n" "$1" "$2"

    find_path_JSON "$2" path "$result_JSON"

    printf2 "path-R :" "$path"
    printf2  "result_JSON-R-before :" "$result_JSON"

    right=\""$1"\"
    if [ "$path" == '.' ]
    then
        result_JSON="$(jq \
"add(.r.v=$right) | add(.r.l={}) | add(.r.r={})" \
                      <<<"$result_JSON")"
    else
      result_JSON="$(jq \
"add($path.r.v=$right) | add($path.r.l={}) | add($path.r.r={})" \
                      <<<"$result_JSON")"
    fi

  printf2 "result_JSON-R :" "$result_JSON"
}

mk_Sat () {

  pre_Order="$1"
  in_Order="$2"

  declare -A result=()

  #
  # First iteration
  #
  root="${pre_Order%% *}"
  pre_Order="${pre_Order#* }"
  post_Order="$root"" "
  
  result_JSON="$(jq \
     "add(.v=\"$root\") | add(.l={})   | add(.r={})" <<<'{}')"


  printf2 "result_JSON1 :" "$result_JSON"

  result["root"]="$root"
  
  printf2 "post_Order:" "$post_Order"
  printf2 "pre_Order:" "$pre_Order"

  while true 
  do
    val="${pre_Order%% *}"
    pre_Order="${pre_Order#* }"

    val2="$val" ; last=0 ; left="leftf"
    while { [[ "$last" -ne 1 ]] \
         && [[ ! "$post_Order" =~ $left ]] }
    do
      left="$(pos_in_LR "$val2" 'l')"
      printf2 "val: %s left W1: %s val2 W1:%s\n" \
                  "$val"      "$left"   "$val2"
      [ "$left" == "" ] && break
      val2="$left"
    done

    if [ "$left" != "" ]
    then

      add_Left "$val" "$left"

    else
      val2="$val" ; last=0 ; right="riight" 
      while [[ "$last" -ne 1 ]] \
         && [[ ! "$post_Order" =~ $right ]]
      do
        right="$(pos_in_LR "$val2" 'r')"
        val2="$right"
        printf2 "val: %s right W1: %s val2 W1:%s\n" \
                    "$val"      "$right"   "$val2"
      done
    
      add_Right "$val" "$right"

    fi

    post_Order+="$val"" "

    printf2 "post_Order:" "$post_Order"
    printf2 "pre_Order:" "$pre_Order"

    # A leak made useful..
    #
    [ "$pre_Order" == "$val" ] \
      && pre_Order="" && break 
  done
  printf2 "pre_Order:" "$pre_Order"

  shopt -s extglob

  for i in ${!result[@]}
  do
    printf2 "!result: %s -> %s result\n" "$i" "${result["$i"]}"
  done

  # Here result is json "pretty"
  #
  printf2 "result_JSON :" "$result_JSON"

  # From "pretty" json to "@tests" form..
  #   a good exercism from reg forms 
  #   to bash patterns var substitution
  #   looks rather incomprehensible though..
  #
  #   ( better use intermediate language :
  #      - 'yq' (*not* installed on exercism's 
  #              site but 'jq' *is* there indeed !)
  #      is very versatile : 
  #        from 'yaml' to 'p' or 'shell' -
  #     for solution's construction then  
  #     translate it to json )
  #

  # 1st orphaned leafs on a single line
  #
reg1='"(r|l)": {'$'\n[ ]*"v": "([[:alnum:]])+",'$'\n''( )*"l": {},'$'\n''( )*"r": {}'$'\n''( )*}(,)?'$'\n'
reg2='"(r|l)": {'$'\n''( )*"v": "*([[:alnum:]])+",'$'\n''( )*"l": {},'$'\n''( )*"r": {}(,)?'
  while [[ "$result_JSON" =~ $reg1 ]]
  do
    [[ "$result_JSON" =~ $reg2 ]]
    result_JSON=\
"${result_JSON/\""${BASH_REMATCH[1]}"\": \{$'\n'*( )\"v\": \""${BASH_REMATCH[3]}"\",$'\n'*( )\"l\": \{\},$'\n'*( )\"r\": \{\}$'\n'*( )/\""${BASH_REMATCH[1]}"\": \{\"v\": \""${BASH_REMATCH[3]}"\", \"l\": \{\}, \"r\": \{\}}"  
                # "${BASH_REMATCH[4]}" was <space> 
                #   eventually for trailing pretty : '} }'
  done

  # 2d remove some newlines 
  #   ( after "(r/l)..v {" pattern )
  #
reg1='"(r|l)": {'$'\n''[ ]*"v": "([[:alnum:]])+",'$'\n'
reg2='"(r|l)": {'$'\n''[ ]*"v": "*([[:alnum:]])+"'
  while [[ "$result_JSON" =~ $reg1 ]]
  do
    [[ "$result_JSON" =~ $reg2 ]]
    result_JSON=\
"${result_JSON/\""${BASH_REMATCH[1]}"\": \{$'\n'*( )\"v\": \""${BASH_REMATCH[2]}"\",$'\n'/\""${BASH_REMATCH[1]}"\": \{\"v\": \""${BASH_REMATCH[2]}"\",$'\n'}"
  done
    result_JSON=\
"${result_JSON/\{$'\n'*( )/\{}"
  
    #yq -oj <<< "$result_JSON"
    echo "$result_JSON" # useless : | sed 's/^/    /'



if [[ "$DEBUG" -gt 1 ]]
then
  echo "${result_JSON//[[:space:]]/}"
        while read -r line 
        do
          echo "-$line-"
        done < <(echo "$result_JSON")
  expectedJson=$(cat << END_JSON
    {"v": "a",
        "l": {"v": "i", "l": {}, "r": {}},
        "r": {"v": "x",
            "l": {"v": "f", "l": {}, "r": {}},
            "r": {"v": "r", "l": {}, "r": {}}
        }
    }
END_JSON
)
  echo "${expectedJson//[[:space:]]/}"
        while read -r line 
        do
          echo "-$line-"
        done < <(echo "$result_JSON")
fi
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
                #mk_Sat $Args
                mk_Sat "${Input[@]}"
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 170 days...
