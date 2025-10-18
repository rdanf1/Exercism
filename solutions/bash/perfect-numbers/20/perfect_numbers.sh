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

recurent_Deb () {

  if [[ "$recurent" -eq 1 ]]
  then
    h_Option="-h"
  else
    h_Option=""
  fi

  wc=$(factor $h_Option "$1" | sed 's/.*: //' | wc -w)
  printf2 "wc :" "$wc"

  Fact=() ; for i in $(factor $h_Option "$1" \
                     | sed 's/.*: //')
            do 
              Fact[wc-1]="$i"
              ((wc--))
            done
}
#########
# Maths #
#========
# Preamble :
# You may argue that searching all multiples
#  of a number is not necessary to know if
#  it's perfect, deficient or abundant
#  though that's THE entertaining/challenging
#  purpose here, this say, I'll be back to it...
#
# The Main idea is to use "atomic resolution"
# ie N = Pⁿ // S_Pn(Pⁿ) (1) and in a way 
# "distribute" those trivial solutions with 
# numbers having 2 primes within their factors //
#   N = P₁ʳ.P₂ˢ [2]
# then 3 primes within, then 4, etc..
#
# Searching this for [2], 
# an intuitive formula appears that may be correct
# in some cases with 2 primes composed Numbers
# in particular this formula is correct for
#
#       squares              : N = P₁².P₂² [2a]
#       perfects (and more!) : N = 2ⁿ.P    [2b]
#   others (with conditions) : P₁ʳ.P₂ˢ     [2c]
#                        when  P₂ˢ > P₁
# this simple formula
# gives sum of factors S_Pn(P₁ʳ.P₂ˢ) > (actual/real sum)
#                 when P₂ˢ < P₁
# but when substracting to it other formulas we can
#  say that [2] is solved !
#
# Trying 1 level more ( 3 primes in N ) seems
# much more difficult...
##################################
# Maths is a neverending story.. =
#=================================
 
 
# Set/Echo Sum of multiples of Pⁿ
#  ( including Pⁿ )
#  
recure_S_Pn () {

  P="$1" ; n="$2"

  if [[ "$n" -gt "1" ]]
  then
    P_n="$((P**n))"
    sum+="$P_n"

    # For further use..
    #  ( var ineffective when 
    #    funcº used in $() 
    #    should proceed in other ways )
    #
    Sn["$P"]+="$P_n "

    # board effect !!
    #  ( this function is not 
    #    supposed to return this )
    #
    #echo P_n $P_n

    recure_S_Pn "$P" "$((n-1))"
  else
      sum+="$(($1+1))"
      Sn["$P"]+="$1 1"
      echo $sum
  fi
    sum=0
}

set_Pn_Sn_arrays () {

i=0
for P_n in "${Fact[@]}" 
do
    printf2 "P_n : ==%s==\n" "$P_n"

    if [[ "$P_n" =~ '^' ]] ; then
      Pn[i]="${P_n/^*/}"
      En[i]="${P_n/*^/}"
    else 
      if [ "$P_n" != "" ] ; then
        Pn[i]="$P_n"
        En[i]="1" 
      fi
    fi

    printf2 "%s--%s\n" "${Pn[i]}" "${En[i]}"

    #           vv *Not* vv same shell => 2d call
    S_Pn[i]="$(recure_S_Pn "${Pn[i]}" "${En[i]}")"
    # => 2d time for Sn values ok 
    #   (set in recure fct)
    recure_S_Pn "${Pn[i]}" "${En[i]}" "1" >/dev/null
    
    # HS
    #while read -r S_Pn[i]
    #do
    #  :
    #done < <(recure_S_Pn "${Pn[i]}" "${En[i]}")

    printf2 "S_Pn :" "${S_Pn[@]}"
    printf2 "Pn :" "${Pn[@]}"
    printf2 "En :" "${En[@]}"

    printf2 "Sn[Pn[0]] :" "${Sn["${Pn[0]}"]}"
    #printf2 "Sn[Pn[1]] :" "${Sn["${Pn[1]}"]}" 2>/dev/null
    #printf2 "Sn[Pn[2]] :" "${Sn["${Pn[2]}"]}" 2>/dev/null
    printf2 "Sn[@] :" "${Sn[@]}"

    ((i++))

done 

}

Main () {

  [[ "$1" -eq 1 ]] && Result=0 && End "$Result" "$1"

  declare -i recurent=1 result=0 N="$1" sum=0

  declare -a S_Pn=() Pn=() En=()

  declare -A Sn=()  # to be exported ?!..
                    # (see recure fct )

# Board effects (Sn) !
#recure_S_Pn 2 10 1
#recure_S_Pn 2 4
#recure_S_Pn 3 4

#printf  "S 2 3 : \n"
#recure_S_Pn 2 3
#printf  "S 3 1 : \n"
#recure_S_Pn 3 1

  recurent_Deb "$@"

  printf2 "Fact :" "${Fact[@]}"

  set_Pn_Sn_arrays "$@"


  [[ "${#Pn[@]}" -eq 1 ]] && \
    echo "$((S_Pn[0] - Pn[0]*En[0]))" && exit 0


  Nb_P="${#Pn[@]}"

  max_iSn="$((Nb_P - 2))"
  max_Sn="$((Nb_P - 1))"
  printf2 "Nb_Pn:"  "$Nb_P"
  printf2 "max Pn:" "$max_iSn"
  printf2 "max Sn:#" "$max_Sn"

  Sn1="${Sn[${Pn[0]}]}"

  printf2 "Sn1 :" "$Sn1"

  Sn2="${Sn[${Pn[max_Sn]}]}"
  Sn2="${Sn2#[[:digit:]]* }"
  Sn2="${Sn2#[[:digit:]]* }"

  printf2 "Sn2 :" "$Sn2" 
  printf2 "S_Pn[1]:%s / Pn[1] :%s\n" \
          "${S_Pn[1]}" "${Pn[1]}"

  result=0

  SP1="${S_Pn[0]}"
  SP2="$((S_Pn[1] - Pn[1]**En[1]))"

  printf2 "SP1: %s  SP2: %s\n" "$SP1" "$SP2"

  result=$((SP1*SP2))

  printf2 "result :" "$result"


  SP1="$((Pn[1]**En[1]))"
  SP2="$((S_Pn[0] - Pn[0]**En[0]))"

  printf2 "SP1: %s  SP2: %s\n" "$SP1" "$SP2"

  result+=$((SP1*SP2))

  #printf2 "result :" "$result"

  echo "$result"

}

#######################################################

iterative_For_1 () {

for i in "${!Fact[@]}"
do
    result="${Fact[i]}" 
    result2="$(echo "$result" | bc)"
    opposite=$((N/result2)) 
    #result3+="$result2 : $result"$'\n' 
    result3+="$result2, $opposite] : $result"$'\n'
done

# Irrelevant/Wrong  here see 'For_2'
#x1_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
x1_res=$(echo "$result3" | sort -n)

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
# ---------- End of 'structure' ----------
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

###########
# Maths ! #
###########
   # Simplier should be using S(2ⁿ) = 2ⁿ - 1
   #       or should be using S(3ⁿ) = 3ⁿ / 2 
   #       or should be using S(5ⁿ) = 5ⁿ / 2²
   #       or should be using S(7ⁿ) = 7ⁿ / (3*2)
   #       or ...
   #
   #      and by definition of S(N) (recursive!) 
   #      when N=Pⁿ (P prime)
   #          S(Pⁿ) = Pⁿ⁻¹ + Pⁿ⁻² +..+ P¹ + P⁰  (!)
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
# Prop./Theo./Hyp. 1: 
#   let N = P₁ˢ and N' = P₂ᵗ  //  ∀ (P₁,P₂,s,t) ∈ ℕ⁴
# If we know components S(N) & S(N') Then :
#    S(N.N') = ((s+t)/2 -1).S(N).S(N')          (?)
#            + ((s+t)/2).S(N) + ((s+t)/2).S(N') (?)
#   [ OR? .. + s.S(N) + t.S(N')                 (?) ]
# If we  let s = t = n Then :
#  S(N.N') = (n-1).S(N).S(N') + n.S(N) + n.S(N')(!)
# (?) : Need verification.. => !Only true in some cases!
# (!) : Obvious !                      ( n=2, .. )
# ================================================
# TODO: This solution needs more maths into it ! #
##################################################
# Maths : N0T Done ! #
######################

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

  Factors="$(factor -h "$N" | cut -d' ' -f 2-)"

  Fact_R=() ; for i in $Factors
              do Fact_R+=( "$i" ) ; done
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

  # Force YES recurence (Actually 28 fails recurencelly)
  [ "$4" == "R" ] || [[ $((N % 256)) -eq 0 ]] \
    && recurent=1

  # Force NO recurence except if very much too loooooong
  [ "$4" == "r" ] \
    && recurent=0
  
  recurent_Deb2 "$@"
  [[ "${Fact_R[0]}" =~ '^' ]] && \
  [[ "$(bc <<<"${Fact_R[0]}")" -eq "$N" ]] && \
  [[ "$recurent" -eq 1 ]] && \
  Two_s=1

     printf2 "Fact_R[@] :" "${Fact_R[@]}" 
     printf2 "Fact_R[0] :" "${Fact_R[0]}" 
     printf2 "#Fact_R[@] :" "${#Fact_R[@]}" 
     #[[ "${Fact_R[0]}" =~ '^' ]] && \
     if \
     [ ! "$2" == 'o' ]  && \
     [[ "${#Fact_R[@]}" -eq 2 ]]  # && \
     #[[ "${Fact_R[0]}" =~ '2^' ]] && \
     #[[ -n "${Fact_R[1]}" ]] && \
     #[[ ! -n "${Fact_R[2]}" ]] 
     then
        # Fast algorithm
        Result=$("./$0" "$N" 1)

        #[[ "$Result" -lt 0 ]] && Result="$((-Result))"
        End "$Result" "$N"
     fi

  recurent_Deb1 "$@"

  printf2 "Fact[@]" "${Fact[@]}"

  Nb_p="${#Fact[@]}"
  Max_i="$((Nb_p - 1))"
  printf2 "Number  is   :" "$N"
  printf2 "Factors are  :" "$(factor $N)"
  printf2 "Number of factors :" "$Nb_p"
  printf2 "Number of indices :" "$Max_i"

# Is wrong 
#broken=$(($Nb_p/2))

# Is OK !
#
declare -i middle=1 opposite=2
for i in "${!Fact[@]}"
do
  if [[ "$middle" -lt "$opposite" ]]
  then
    Fact_nb=$(bc <<<"${Fact[i]}")
    ((middle*=Fact_nb))
    opposite="$((N / middle ))"
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

     result3=""
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

End () {

  if [[ "$1" -eq "$2" ]]
  then
    # very rare ! Some (2^n + P) structures
    echo "perfect"
  else
    if [[ "$1" -lt "$2" ]]
    then
        # most cases
        echo "deficient"

        printf2 "Result is :" "$1"
    else
        # relatively rare..
        echo "abundant"

        printf2 "Result is :" "$1"
    fi
  fi

  exit 0
}

main () {

declare -i sum=0  sum_2=0 Once=1 N=0 Result=0 top=0
                  Two_s=0 Once2=0

  get_Factors "$@"

  End "$Result" "$1"

}

case "$2" in
  1) 
    Main "$@"
    ;;
  *)
    main "$@"
    ;;
esac

# DR -- Very Challeng\ng ! --
