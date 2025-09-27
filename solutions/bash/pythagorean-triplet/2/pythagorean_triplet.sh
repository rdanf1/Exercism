#!/usr/bin/env bash
# Maths : 3 formulas                              / k > l
#             a  < b  < c         [1] => b = a + n, c = a + m [i]
#             a² + b² = c²        [2]
#             a  + b  + c = N     [3]
#
# and we know ∃ p, q ∈ ℕ and p > q :
#    (2pq)² + (p² - q²)² = (p² + q²)²
#      a         b           c
#      =         =           =
# then [3] becomes :
#    (2pq) + (p² - q²) + (p² + q²) = N [4]
#
# <=> N/2 = p(p+q) [4']  
#
# NB: says also (p,q)   is uniq solution for given N 
#            so (a,b,c) is uniq too
#
# The hard stuff, with N known, 
#     is to turn [4'] into an efficient algorithm :
#
#     1- with minimal value for q=1 (q₁):
#
# [4'] => N/2 = p(p+1) [5]
#
#     2- finding p₁ max for [5] (with q=1) :
#
#         browsing with p = 1, 2, 3, ..
#         then p₁ max as p₁(p₁+1) > N/2       or if '=' solved !
#      
#     3- switch/test with values p=(p-1) and q=(q+1)
#        then increase q while p(p+q) < N/2   or if '=' solved !
#
#     4- if p(p+q) > N/2 re-iterate as 3-     or if '=' solved !
#
#     5- End condition q max = p - 1 
#                  and no equality/solution was found
#
#  ====> Full Maths approach with equations and inequation
#         seems just more complicated/complex than 
#         the succession of approximations of N above
#
#  ====> 2- is improved if we start from p₁ = int(sqrt(N/2)
#
###############################################################
# Changing formulas because 2pq, p²-q², p²+q² 
#                         as a, b , c aren't ALL Solutions !!!
#
# 1. If we set b=a+p and c=a+q [i] => here p < q and (p,q) ∈ ℕ²
#
#       then [3]   <=> p + q = N - 3a      [3']
#
# 2. From    [2]   <=> a² = (a+q)² - (a+p)²
#                  <=> a² = 2a(q-p) + (q-p)(q+p)
#                  <=> a² = (2a+q+p)(q-p)
#       with [3]   <=> a² = (N - a)(q - p)  so :
#                  <=> a²/(N - a)=(q - p) [2']  (means ∈ ℕ)
#
# 3. We search (q - p) browsing ℕ set with 'a' that verify [2']
#    nb : ℕ={1, 2, 3, ..} = set of natural numbers
#
# 4. When q - p value is found we deduce p and q with [3']
#
# 5. We continue 3. (testing values of 'a' browsing ℕ
#    that verify [2']) until maximum is reached meaning
#    stop condition is [3'] with min (p,q) = (1,2) :
#                        a + (a+1) + (a+2) > N
#                        a > (N-3)/3
# #############################################################
#
# NB : There must be a more restrictive stop condition with [2']
#                                                        or [3']
# NB2: There must be a more effective starting point
#      for a than browsing from starting with a=1.. if N is big.
# NB3: This implementation sometimes gives false sol when N odd
#      => treated before as if N is odd => no solution !!
#      (though I dont have proof of that, except several tests..) 
# NB4: The commented @test with N=30000 takes 0.542s !!!!
#      => thats NOT brute forced indeed !!
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
  while [[ "${Input[i]}" =~ "^$" ]] || \
  [ "${Input[i]}" == "" ] 
  do
      unset "Input[i]"
      ((i--))
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
"^$REGEX_PARAM1$" 

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

mk_Sth () {
  a=0
  N="$1"
  # Odds values for N wont do it.. 
  # ( though not an error and no proof of that.. )
  [[ "$((N % 2 ))" -eq 1 ]] && exit 0
  a_max="$(( (N - 3)/3 ))"

  while [[ "$a" -lt "$a_max" ]]
  do
    ((a++))
    a_2="$((a*a))"
    q_p=$(( a_2/(N-a) ))

    # [[ "$q_p" -eq 0 ]] && continue # tested after..

    if [[ "$(( q_p*(N-a) ))" -eq "$a_2" ]]
    then
      q="$(( (N - 3*a + q_p)/2 ))"
      p="$(( N - 3*a - q ))"
      printf2 "p:%s, q:%s\n" "$p" "$q"
      # Weired condition but necessary..
      #  ( test without with N=840 )
      if [[ "$p" -gt 0 ]]
      then
        echo "$a,$((a+p)),$((a+q))"
      else
        break
      fi
    fi
    
  done
}

main () {
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

# DR - Ascension 2025 plus: 122 days...
