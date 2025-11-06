#!/usr/bin/env bash
#
# 4 things to know : 
#
#   0. '::' thing is Just a name convention..
#        'list::<op>' is the name of the function
#         (lets say it is from 'lists' "family"..)
#
#   1. folds operate with pair of values from list..
#        ie : with list=(1 2 3 4) ;
#             initiated by elem=24
#                                    
#        list::foldl div 24 list => 24/(1/2)/(3/4) = 64  (*)
#        list::foldr div 24 list => 24/(4/3)/(2/1) = 9   (*)
#
#   2. "" is invariant for 'mult'..
#
#   3. WTH is the purpose of those 
#        "distinct" functions : 'foldl' / 'foldr'
#       when using "distinct" : 'div'   / 'concat'
#        for each one ?!..
#        Expect *All* messing it up, I dunno (IMHO...)
#
#   4. 'source' is a painful when using nref vars..
#        meanwhile it *is* an interesting novelty ! :)
#
#   nb: 0, 1, 2 are deduced from @test though..
#
#   (*) : Using 'bc -l' ( long format ! )
#

DEBUG=0

IFS=' '

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

list::append () {

  IFS=' '
  local -n list1="$1"
  shift
  list2="$*"
  
  list1=( ${list1[*]} $list2 )
  return $?
}

list::filter () {

  IFS=' '
  isOdd1="$1"
  local -n list3="$2" result1="$3"
  j=0 
  result1=()
  
  for i in "${!list3[@]}"
  do
    if { "$isOdd1" "${list3[i]}" ;}
    then
      result1[j]="${list3[i]}"

      # ! ((j++)) !!..
      # must '<fic>.bats 2>/dev/null | less' with @test 
      # to see the faulty line was here..
      #
      ((j+=1))
    fi
  done

  return $? 
}

list::map () {

  IFS=' '
  incr1="$1"
  local -n list4="$2" result2="$3"
  j=0 
  result2=()
  
  for i in "${!list4[@]}"
  do
    result2[i]="$("$incr1" "${list4[i]}")"
  done

  return $?
}

list::reverse () {

  IFS=' '
  local -n list5="$1" result3="$2"
  result3=()

  j="$((${#list5[@]} - 1))"

  for i in "${!list5[@]}"
  do
    result3[j]="${list5[i]}"
    # ! ((j--)) neither ((j-=1)) .. ..
      # must '<fic>.bats | less' with @test 
    j="$((j-1))"
  done

  return $?
}

list::foldl () {

# Is used.. (rewrite the mess..)
#
div () { local acc=$1 elem=$2; echo "$elem / $acc" | bc -l;}

  func_op1="$1"
  func_param1="$2"
    
  local -n list_dl="$3"
  
  [[ "${#list_dl[@]}" -eq 0 ]] && echo "$2" && return $?

  # Dont ask ( @#!* )
  if [ "$func_op1" == "concat" ]
  then
    reversed=()
    list::reverse list_dl reversed
    local -n list_dl='reversed'
  fi

  result4=()

  IFS=$'\n\t'
  j=0 ; k=0 ; first=1
  # Wrong if ' ' is to manage..
  #IFS=$' '
  while [[ "${#list_dl}" -ge 1 ]]
  do
      # "reduce" list (after repeated pair ops) 
      #    to 1 element
      if [[ -n "${list_dl[1]}" ]]
      then
        result4[k]="$("$func_op1" \
                      "${list_dl[1]}" "${list_dl[0]}")"

        # First pair result is op with initial acc.
        if [[ "$first" -eq 1 ]]
        then
         result4[k]="$("$func_op1" \
                       "${result4[k]}" "$func_param1" )"
         first=0
        fi

        #list=( $( echo ${list[@]} | cut -d$'\n' -f 3- ) )
        # Best way (cuts 3.. values of list array) !
        #  ( for managing spaces, etc.. )
        #
        list_dl=( ${list_dl[*]:2} ) 

        printf2 "1_list@ -%s-\n" "${list_dl[@]@Q}"
        printf2 "1_result4@ -%s-" "${result4[@]@Q}"
      else
        result4[k]="${list_dl[0]}"
        printf2 "11_result4@ -%s-\n" "${result4[@]@Q}"
        list_dl=()
      fi

      if [[ "${#list_dl[@]}" -eq 0 ]] \
      && [[ "${#result4[@]}" -ne 0 ]]
      then
        # 'for' some reason 
        #   sometimes i starts at 1..
        #   => using j to keep range
        j=0
        for i in "${!result4[@]}"
        do
          list_dl[j]="${result4[i]}"
          printf2 "2_listI-%s-%s-\n" "$j" "${list_dl[i]@Q}"
          ((j++))
        done
        # mandatory
        [[ "${#list_dl[@]}" -eq 1 ]] && break
        result4=()
        k=0
      else
        printf2 '%s\n' 'EEEEEEEEEELSE'
        [[ "${#result4[@]}" -eq 0 ]] && \
        [[ "${#list_dl[@]}" -eq 1 ]] && break
      fi
      ((k++))

  done

  if [[ -n "${list_dl[1]}" ]] \
  && [[ -n "${list_dl[2]}" ]]
  then
    list_dl="$("$func_op1" "${list_dl[2]}" "${list_dl[1]}")"
  fi
  
  if [ "${list_dl[0]}" == "" ] \
  && [[ -n "${list_dl[1]}" ]]
  then
    list_dl[0]="${list_dl[1]}"
  fi


  # list is reduced to a single elem
  #
  printf2 "list_dl@ :" "${list_dl[@]}"
  printf2 "list_dl0 :" "${list_dl[0]}"
  printf2 "list_dl1 :" "${list_dl[1]}"
  echo "${list_dl[0]}"
  IFS=' '

  return $?
}

# Almost done from above..
#
# nb : not using 'list1' neither 'result'
#              => "circular ref" bash warnings
list::foldr () {

  funct2="$1"
  funct_param2="$2"
  local -n list6="$3"
  result5=()

  if [ "$funct2" == "div" ]
  #   [ "$funct2" == "concat" ]
  then
    list::reverse list6 result5
    list::foldl "$funct2" "$funct_param2" result5
  else
    list::foldl "$funct2" "$funct_param2" list6 
  fi

  return $?
}

# DR - 04/11/2025
