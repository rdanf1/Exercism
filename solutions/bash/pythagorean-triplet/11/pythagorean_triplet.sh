#!/usr/bin/env bash
# Maths : 3 formulas                              / k > l
#             a  < b  < c         [1] => b = a + n, c = a + m [i]
#             a² + b² = c²        [2]
#             a  + b  + c = N     [3]
#
###############################################################
#
# 1. If we set b=a+p and c=a+q [i] => here p < q and (p,q) ∈ ℕ²
#
#       then [3]   <=> p + q = N - 3a      [3']
#
# 2. From    [2]   <=> a² = (a+q)² - (a+p)²
#                  <=> a² = 2aq - 2ap + q² - p²
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
# NB3bis : Keep false sol, rename it to "nearest N odd sol." !!!!!
#          => see N=260015  gives 8  "nearest" (N=5*7*17*19*23)
#                 N=7540435 gives 21 "nearest" (N=5*7*17*19*23*27)
# NB4: The commented @test with N=30000   takes ~  0.5s !!
#                               N=300000  takes -  5.0s !!!
#                               N=3000000 takes - 50.0s !!!!
#      => thats NOT brute force indeed !!
# NB5: Algorithm easy for parallellisation on several machines..
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

Comment="$( cat << End
  -_-

$ time $0 3000000

gives :

120000,1437500,1442500
187500,1400000,1412500
440000,1242188,1317812                                            500000,1200000,1300000
600000,1125000,1275000
656250,1080000,1263750
696000,1046875,1257125
750000,1000000,1250000

real    0m42.688s
user    0m41.339s
sys     0m1.350s

====================================================

And a sample with a "nearly triangle-rectangle"
 when N is Odd !!! => Needs to comment Line 272 (& uncmt 274) !
$ time $0 2600005

gives ( always 0 or 1 value returned => NO :
           N=2600017 return 2 "nearly triangle-rectangle" !!!!!
           "390980,1069919,1139118"
       and "601160,909029,1089828" 
       => to be mathematically studied further I think...
       => see NB3bis on top REMs !!!!) : 

131964,1230493,1237548
                                                                  real    0m36.296s
user    0m35.030s
sys     0m1.266s

means :

bc 1.08.2
> 131964^2+1230493^2;1237548^2
> 1531527520345
> 1531525052304
> scale=16
> 1531525052304/1531527520345
> .9999983885101852      => 0.00027% rectangle approximation !!!

End
)"

mk_Sth () {
  a=0
  N="$1"
  # Odds values for N wont do it.. 
  # ( though not an error and no proof of that.. )
  [[ "$((N % 2 ))" -eq 1 ]] && exit 0
  # Uncomment next line when comment above line
  #printf "\n%s: " "$N"
  # and $ $0 <<< $(echo {250001..250099..2} \
  #        | sed 's/ /\n/g') 2>/dev/null
  # as sample script use for many "Odds" tests.. :)
  
  a_max="$(( (N - 3)/3 ))"

  while [[ "$a" -lt "$a_max" ]]
  do
    ((a++))
    a_2="$((a*a))"
  
    # Makes it a bit faster (~10% increasing with N..) 
    #   (~ -4.5s / 47s / N=3000000 )
    mod="$(( a_2 % (N-a) ))"
    if [[ "$mod" -eq 0 ]]
    then

    q_p=$(( a_2/(N-a) ))

    # [[ "$q_p" -eq 0 ]] && continue # tested after..

    if [[ "$(( q_p*(N-a) ))" -eq "$a_2" ]]
    then
      q="$(( (N - 3*a + q_p)/2 ))"
      p="$(( N - 3*a - q ))"
      printf2 "p:%s, q:%s\n" "$p" "$q"
      # Weird condition but necessary..
      #  ( test without with N=840 )
      if [[ "$p" -gt 0 ]]
      then
        echo "$a,$((a+p)),$((a+q))"
      else
        break
      fi
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
                echo "$Comment"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 122 days...
