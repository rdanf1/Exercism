#!/usr/bin/env bash
#
# Debug mode printf
DEBUG=0

printf2 () {
  if [[ "$DEBUG" -gt "0" ]] ; then
    if [[ "$1" =~ '%' ]] ; then
        printf "$@"
     else
        printf '%s\n' "$*"
  fi ; fi
  return 0
}

# Test portions of code syntax
#
o=$(test << Fin
... <Code to exclude> ...
Fin
)

iterative_For_1 () {

for i in "${!Fact[@]}"
do
    result="${Fact[i]}" 
    result2="$(echo "$result" | bc)"
    opposite=$((N/result2)) 
    #result3+="$result2 : $result"$'\n' 
    result3+=( "$result2, $opposite] : $result"$'\n' )
done

# Irrelevant/Wrong  here see 'For_2'
#x1_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
x1_res=$(echo "$result3" | sort -n)

# $N is prime..
#else
#  sum+=1
#  return 0
#fi
}

iterative_For_2 () {

if [[ "$broken" -ge 2 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    result="${Fact[i]}*${Fact[j]}" 
    result2="$(echo "$result" | bc)"
    opposite=$((N/result2)) 
    #result3+="$result2 : $result"$'\n' 
    result3+="$result2, $opposite] : $result"$'\n'
  done ; done
fi

# Use this to compare with line 95 !
#echo "$result3" | sort -n
# Necessary even when breaks are ok 
#           (a*a*.. / a^n forms !)
#
# Just what I wanted !!! ( remove commutativity doubles )
#  Beautiful: removes dup on 1st wrd input line (tiple)
#                                   --vvvvv--
#echo "$result3" | sort -n | uniq -w "${#_}"

x2_res=$(echo "$result3" | sort -n | uniq -w "${#_}")

}

iterative_For_3 () {

if [[ "$broken" -ge 3 ]] ; then
# NB: "${!Fact[@]}" is much more faster
#                      than "$(seq ..)" (sub shell!!)
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || \
      [ "$j" == "$k" ] && break
      result="${Fact[i]}*${Fact[j]}*${Fact[k]}" 
      result2="$(echo "$result" | bc)"
      opposite=$((N/result2)) 
      result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done
fi

x3_res=$(echo "$result3" | sort -n | uniq -w "${#_}")

}

iterative_For_4 () {

if [[ "$broken" -ge 4 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        result="${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}" 
        result2="$(echo "$result" | bc)"
        #[[ $opposite -eq $result2 ]] && \
        #  echo ===$opposite=== && broken=1 && break 4 
        opposite=$((N/result2)) 
        result3+="$result2, $opposite] : $result"$'\n'
        #((c++))
        #[[ "$result2" -eq "3135" ]] && broken=1 \
        #  && echo c : $c && break 4
  done ; done ; done ; done
fi

x4_res=$(echo "$result3" | sort -n | uniq -w "${#_}")

}

iterative_For_5 () {

if [[ "$broken" -ge 5 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in "${!Fact[@]}" ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done
fi
x5_res=$(echo "$result3" | sort -n | uniq -w "${#_}")

}

iterative_For_6 () {

if [[ "$broken" -ge 6 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in "${!Fact[@]}" ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in "${!Fact[@]}" ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done
fi
x6_res=$(echo "$result3" | sort -n | uniq -w "${#_}")

}

iterative_For_7 () {

if [[ "$broken" -ge 7 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in "${!Fact[@]}" ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in "${!Fact[@]}" ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in "${!Fact[@]}" ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
fi
x7_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"

}

iterative_For_8 () {

if [[ "$broken" -ge 8 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in "${!Fact[@]}" ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in "${!Fact[@]}" ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in "${!Fact[@]}" ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
        for p in "${!Fact[@]}" ; do
          [ "$i" == "$p" ] || [ "$j" == "$p" ] || \
          [ "$k" == "$p" ] || [ "$l" == "$p" ] || \
          [ "$m" == "$p" ] || [ "$n" == "$o" ] || \
          [ "$o" == "$p" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}*${Fact[p]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
  done 
fi
x8_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"

}

iterative_For_9 () {

if [[ "$broken" -ge 9 ]] ; then
for i in "${!Fact[@]}" ; do
  for j in "${!Fact[@]}" ; do
    [ "$i" == "$j" ] && break
    for k in "${!Fact[@]}" ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in "${!Fact[@]}" ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in "${!Fact[@]}" ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in "${!Fact[@]}" ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in "${!Fact[@]}" ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
        for p in "${!Fact[@]}" ; do
          [ "$i" == "$p" ] || [ "$j" == "$p" ] || \
          [ "$k" == "$p" ] || [ "$l" == "$p" ] || \
          [ "$m" == "$p" ] || [ "$n" == "$p" ] || \
          [ "$o" == "$p" ] && break
        for q in "${!Fact[@]}" ; do
          [ "$i" == "$q" ] || [ "$j" == "$q" ] || \
          [ "$k" == "$q" ] || [ "$l" == "$q" ] || \
          [ "$m" == "$q" ] || [ "$n" == "$q" ] || \
          [ "$o" == "$q" ] || [ "$p" == "$q" ] || break 
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}*${Fact[p]}*${Fact[q]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
  done ; done
fi
#echo "$result3" | sort -n | uniq -w "${#_}"
x9_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"
#date "+%S.%N" && exit

}

sum_Factors () {

# Sample of nameref var
#  in 'for' loop line 378
#
declare -n nref

# Gathering/Summing results from x[1-9]_res vars
# (This 'structure' should be simpified)
# ---------------------------------------
while read -r factor
do 
  if [[ "$factor" -eq "$N" ]]
  then
    top=1
  fi
     printf2 "adding " "$factor"
     ((sum+=factor))
     printf2 "sum is : %s // %s\n" "$sum" "$N"
done \
  < <(for nref in x{1..9}_res
      do
        while read -r a b
        do
          echo "${a//,/}"$'\n'"${b//] : */}"
        done < <(echo "$nref" | sed -r 's/(\*. )/\1\n/g' \
                              | sed -r 's/(\*.. )/\1\n/g')
      done  | sort -nur)
# ---------- End of 'strucrure' ----------
}

recurent_Deb1 () {

  if [[ "$recurent" -eq 1 ]]
  then
    h_Option="-h"
  else
    h_Option=""
  fi

  Fact=() ; for i in $(factor $h_Option $N \
                     | sed 's/.*://')
            do Fact+=( "$i" ) ; done
}

recurent_Deb2 () {

  Factors="$(factor -h "$N" | cut -d' ' -f 2)"
  Factors+=" ""$(factor "$N" \
               | cut -d' ' -f "$((${Factors:2} + 2))-")"

  Fact_R=() ; for i in $Factors
            do Fact_R+=( "$i" ) ; done
}

exp_Recure () {

     # Dont local(ise) this..
     M="$N"

     # End conditions
     while [[ "$((M % 4))" -eq 0 ]] \
        && [[ "$M" -gt 0 ]]
     do
        printf2 "%s--------%s" "$sum" "$M"

        # Actually This is broken at wrong place
        #   => OK ! (otherwise at 3rd pos. max perfect ko)
        get_Factors "$((M / 2))" "$((broken--))" # "Sub"

        printf2 "sum after" "$sum" 

        [[ $M -ne $N ]] && sum_2+=$((2**13 + 1)) \
        && [[ $Once -eq 1 ]] && Once=0
      
        printf2 "sum_2 :" "$sum_2"

        ((M/=2))
     done
     #((sum-=1))
   }      

 sum_Adjustments () {

   printf2 "adding 1.."
   ((sum+=1))
   printf2 "sum is : %s // %s\n" "$sum" "$N"

   # Peculiar case (Level=nb of prime factors..)
   #
   if [[ "$broken" -eq "${#Fact[@]}" ]]
   then
     printf2 "minus 1.."
     ((sum-=1))
     printf2 "sum is : %s // %s\n" "$sum" "$N"
   fi


   # Simplier should be using S(2ⁿ) = 2ⁿ - 1
   #       or should be using S(3ⁿ) = 3ⁿ / 2 
   #       or should be using S(5ⁿ) = 5ⁿ / 2²
   #       or should be using S(7ⁿ) = 7ⁿ / (3*2)
   #     or whatever is formula for S(P) with P prime..
   #
   #       And consequently (Oh my !) :
   #
   #          S(6ⁿ) = S(2ⁿ.3ⁿ) = S(2ⁿ) ∪ S(3ⁿ)
   #                = (n-1).S(2ⁿ).S(3ⁿ) + n.S(2ⁿ) + n.S(3ⁿ)
   #                = (n-1).S(2ⁿ).S(3ⁿ) + n.[S(2ⁿ) + S(3ⁿ)]
   #          S(6ⁿ) = (n-1).(2ⁿ-1).(3ⁿ/2) 
   #                    + n.(2ⁿ-1)
   #                    + n.(3ⁿ/2)
   #
   # REM : More generally with S(N) = Σ [multiples of N]
   #    (taking '.' as arithmetical 
   #                   multiplication sign..)
# =====================================================
# Prop./Theo. 1: 
#   let N = P₁ⁿ and N' = P₂ⁿ  //  ∀ (P₁,P₂) ∈ ℕ²
#
#   If we know components S(N) & S(N')
#   Then  S(N.N') = (n-1).S(N).S(N') + n.S(N) + n.S(N')
#
# =====================================================
#
# TODO: This solution needs this above maths into it !
#
#       ^^^^^^^^^^^^^^^ This is raw !!! ^^^^^^^^^^^^^^
######################################################

   if [[ "$Two_s" -eq 1 ]]
   then
     ((sum-=1))
     printf2 "Minus 1.. (Two_s)"
     printf2 "sum is : %s // %s\n" "$sum" "$N"

     [[ $Once2 -eq 0 ]] && \
     ((sum+=1))         && \
     printf2 "Plus  1.. (Two_s Once)" && \
     printf2 "sum is : %s // %s\n" "$sum" "$N" && \
     Once2=1 
   fi

   if [ "$2" == "Sub" ]
   then
     ((sum+=N))
     printf2 "plus N.. (Sub)"
     printf2 "sum is : %s // %s\n" "$sum" "$N"
   fi
   
   printf2 "sum - sum_2" "$((sum - sum_2))"

 }

get_Factors () {

  REG_DIG='^[[:digit:]]+$'
  [[ "$1" -lt 1 ]] || [[ ! "$1" =~ $REG_DIG ]] && \
  echo  "Classification is only possible for natural numbers." \
  && exit 1

  [[ "$1" -eq 0 ]] && return 

  declare -i N="$1"

  #[[ "$N" -eq 2 ]] && echo "deficient" && exit 0

  #N=$((2*3*5*7*11*13*17*19))
  #N=$((3*5*7*11*13*17*19))
  N=${N:=$((5*7*11*13*17*19))}
  #N=$((2*2*2*2*2))


  #echo $Two_s ${Fact_R[0]} && exit

  # Force YES r#curence (Actually 28 fails recurencelly)
  [ "$4" == "R" ] || [[ $((N % 256)) -eq 0 ]] \
    && recurent=1

  # Force NO recurence except vvvvvvv very much too loooooong
  [ "$4" == "r" ] \
    && recurent=0
  
  recurent_Deb2
  [[ "${Fact_R[0]}" =~ '^' ]] && \
  [[ "$(bc <<<"${Fact_R[0]}")" -eq "$N" ]] && \
  [[ "$recurent" -eq 1 ]] && \
  Two_s=1

  recurent_Deb1

  printf2 "Fact[@]" "${Fact[@]}"
  #exit

  Nb_p="${#Fact[@]}"
  Max_i="$((Nb_p - 1))"
  printf2 "Number  is   :" "$N"
  printf2 "Factors are  :" "$(factor $N)"
  printf2 "Number of factors :" "$Nb_p"
  printf2 "Number of indices :" "$Max_i"

# Is wrong 
#broken=$(($Nb_p/2))

# Is OK !
declare -i middle=1 opposite=2
for i in "${!Fact[@]}"
do
  if [[ "$middle" -lt "$opposite" ]]
  then
    Fact_nb=$(bc <<<"${Fact[i]}")
    ((middle*=Fact_nb))
    opposite="$((N / middle))"
    ((broken++))
  fi
done

    [[ "$3" != "" ]] && broken="$3"
    printf2 "Level is :" "$broken"

for primes in "${Fact[@]}"
do
  if [[ "$primes" =~ '^' ]]
  then
    printf2 "Fact : %s\n" "$primes"
  fi
done

   #date "+%M:%S.%N"
   # For 9x iterations defined above
   #
   for iterat in iterative_For_{1..9}
   do
     "$iterat"

     result3=()
     opposite=0
   done
   #date "+%M:%S.%N"

   # Structure Gathering iteratives for results
   #
   sum_Factors
   #

   # Buggies
   #
   sum_Adjustments "$@"
   #
    
   if [[ "$recurent" -eq 1 ]]
   then
        # Recurence
        #
        exp_Recure
        #
   fi   

   printf2 "sum :" "$sum"
   if [[ "$broken" -eq "$Nb_p" ]]
   then
       #echo "Last $((sum - N))"
       Result="$((sum - N))"
   else
       Result="$((sum - sum_2 - N))"
       #Result="$((sum - N))"
   fi

   # If N wasnt added (and was substracted above)
   #   we restore it !
   [[ $top -eq 0 ]] && Result="$((Result + N))"
   printf2 "Result :" "$Result"

}

main () {

declare -i sum=0  sum_2=0 Once=1 N=0 Result=0 top=0
                  Two_s=0 Once2=0

  get_Factors "$@"

  if [[ "$Result" -eq "$1" ]]
  then
    # very rare ! Some (2^n + P) structures
    echo "perfect"
  else
    if [[ "$Result" -lt "$1" ]]
    then
        # most cases
        echo "deficient"
    else
        # relatively rare..
        echo "abundant"
    fi
  fi
}

main "$@"

# DR -- Very Challeng\ng ! --
