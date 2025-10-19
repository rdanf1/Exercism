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

################################################
########## PART III ### ευρεΚα ᵪ (τω) ##########
################################################

recurent_Deb () {

  recurent=1

  if [[ "$recurent" -eq 1 ]]
  then
    h_Option="-h"
  else
    h_Option=""
  fi

  wc=$(factor $h_Option "$1" | sed 's/.*: //' | wc -w)

  # a bug !!
  #printf2 "wc :--%s--\n" "$wc"

  Fact=() ; for i in $(factor $h_Option "$1" \
                     | sed 's/.*: //')
            do 
              Fact[wc-1]="$i"
              ((wc--))
              [[ "$wc" -lt 0 ]] && break
            done
}

S1_Pn () {

  P="$1" ; n="$2"

  if [[ "$P" -eq 2 ]]
  then
      echo "$(( P**n - 1 ))"
  else
      echo "$(( P**n / (P-1) ))"
  fi

}

S2_Pn () {

  P1="$1" ; n1="$2"
  P2="$3" ; n2="$4"

# Calculate U₀  ( n & n-1 of "suite U"
#                 we start at the end.. )
#
if [[ -n "$3" ]]
then

#echo P1**n1 -$((P1**n1))- P2**n2 -$((P2**n2))-

  # P1^n1 must be greater than P2^n2
  #  otherwise exchange them
  #
  [[ $((P1**n1)) -lt $((P2**n2)) ]] \
    && { P="$P1"  ; n="$n1"
         P1="$P2" ; n1="$n2"
         P2="$P"  ; n2="$n"
       }

#echo P1^n1 -$P1^$n1- P2^n2 -$P2^$n2-

#S1_Pn "$P1" "$((n1 + 1))"
#S1_Pn "$P1" "$n1"
#S1_Pn "$P2" "$n2"

  # See [th.1]
  #
  Result_Fn=$(( \
            $(S1_Pn "$P1" "$((n1 + 1))") \
          * $(S1_Pn "$P2" "$n2") \
          + $(S1_Pn "$P1" "$n1") \
          * P2**n2 ))

  # Need to store this for 2d part of [prop.1]
  Prev_F=$((P1**n1*P2**n2))
else
  #
  # Calculate Uᵪ (n-2 down to U₁..)
  #
  Result_Fn=$((
            Result_Fn \
          * $(S1_Pn "$P1" "$((n1 + 1))") \
          + $(S1_Pn "$P1" "$n1") \
          * Prev_F ))
  
  # Need to store this for 2d part of [prop.1]
  ((Prev_F *= P1**n1))
fi
#echo "$Result_Fn"
}

P_Exp () {

  p_exp="$1"

  case "$2" in
    'P')
        if [[ "$p_exp" =~ '^' ]]
        then
          echo "${p_exp/^*}"
        else
          echo "$p_exp"
        fi
      ;;
    'E')
        if [[ "$p_exp" =~ '^' ]]
        then
          echo "${p_exp/*^}"
        else
          echo "1"
        fi
      ;;
    *) 
      echo "error Number P^n : $p_exp"
      ;;
  esac
}

recure_S2_Pn () {

    odd="${#Fact[@]}" 

# DONT ASK.. :(
if [[ "$((odd % 2))" -eq 0 ]]
then
    for i in "${Fact[@]}"
    do
       ((odd++))
       [[ "$((odd % 2))" -eq 1 ]] && \
       j=$i && continue
    done
else
#echo top $top
    top=1
    for i in "${Fact[@]}"
    do
       ((odd++))
       [[ "$((odd % 2))" -eq 1 ]] && \
       j=$i && continue
       [[ $top -eq 1 ]] && j="" && top=0
    done
fi

#echo $j--$i
       Fact2="${Fact[*]}"
       Fact2=$(echo "$Fact2" | \
         cut -d' ' -f -$((${#Fact[@]}-2)) 2>/dev/null)
       Fact=( $Fact2 )
      
       P2=$(P_Exp "$i" 'P') ; n2=$(P_Exp "$i" 'E')
       P1=$(P_Exp "$j" 'P') ; n1=$(P_Exp "$j" 'E')

#echo ==$P1==$n1==
#echo ==$P2==$n2==

       if [ "$U_o" != "OK" ]
       then
           # U₀ is first/last element of serie Uᵪ
           #
           S2_Pn "$P1" "$n1" "$P2" "$n2"
           U_o="OK"
       else
           # Uᵨ are others elements of serie Uᵪ
           #
#echo S2_P2 $P2 $n2
#echo S2_P1 $P1 $n1
           # Should sort all these though !?..
           if [[ $((P1 ** n1)) -gt $((P2  ** n2)) ]]
           then
#echo S2_P1 $P1 $n1
               P_Prev=$P2 E_Prev=$n2
               [[ -n "$P1" ]] && \
               S2_Pn "$P1" "$n1"
#echo Prev $P_Prev $E_Prev
               [[ "$P_Prev" != "$P1" ]] && \
               S2_Pn "$P_Prev" "$E_Prev"
           else
#echo S2_P2 $P2 $n2
               P_Prev=$P1 E_Prev=$n1
               [[ -n "$P2" ]] && \
               S2_Pn "$P2" "$n2"
#echo Prev $P_Prev $E_Prev
               [[ "$P_Prev" != "$P2" ]] && \
               S2_Pn "$P_Prev" "$E_Prev"
           fi

#echo S2_P2 $P2 $n2
#echo S2_P1 $P1 $n1
       fi

#echo Fact2: $Fact2 && echo "$Result_Fn" && read q
       [[ ${#Fact2} -eq 0 ]] && echo "$Result_Fn" \
                             && return
       recure_S2_Pn
}


#S2_Pn "7" "1" "2" "2"
#exit

Main_Atom () {

  recurent_Deb "$@"

  recurent=1

  if [[ ! "${Fact[0]}" =~ '^' ]]
  then
      P1="${Fact[0]/^*}" n1="1"
  else
      P1="${Fact[0]/^*}" n1="${Fact[0]/*^}"
  fi
  

# Bugs, why ?!.. =>> Dont recurse well !
#
  #printf2 "Fact[0] : " "${Fact[0]}"
  #printf2 " P1: " "$P1"
  #printf2 " n1: " "$n1"

  case "$3" in
   1)
     S1_Pn "$P1" "$n1"
     ;;
   2)
     recure_S2_Pn "$@"
     ;;
   *) echo Pb
     ;;
  esac
}

##########################################################

########### This is Not B...S..t
# Maths #
#========
# Preamble :
# You may argue that searching all multiples
#  of a number is not necessary to know if
#  it's perfect, deficient or abundant
#  though that's THE entertaining/challenging
#  purpose here, this said, I'll be back to it...
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
#  P₁,P₂ Primes ; (n, r, s) ∈ ℕ³
#
#       squares              : N = P₁².P₂² [2']
#       same exponents       : N = P₁ⁿ.P₂ⁿ [2']
#       perfects (and more!) : N = 2ⁿ.P    [2'']
#       others               : N = P₁ʳ.P₂ˢ [2]
#
# this simple formula is when posing
#       S (P₁ʳ) = P₁ʳ   + S'(P₁ʳ) 
#  and  S'(P₁ʳ) = P₁ʳ⁻¹ + P₁ʳ⁻² + .. + P₁ + 1
#
# [3] : Sol(P₁ʳ.P₂ˢ) = S (P₁ʳ) . S'(P₂ˢ)   [3a]
#                    + P₂ˢ     . S'(P₁ʳ)   [3b]
#
# Using '.' for arithmetic multiplication
# We can say that [2] is solved !
#
# Trying 1 level more ( 3 primes in N ) seems
# much more difficult though...
# 
# if we 'set back' with function notations
# we can verify that this recursive equation
#  works fine !!! 
#               
#  F₂(x.y)   = F₁(x+1).F₁(y) + F₁(x).y              [th.1]
#
#  F₃(x.y.z) = F₁(x+1).F₂(y.z) + F₁(x).y.z
#                                                  [prop.1]
# F₃ = F₁(x+1).[ F₁(y+1).F₁(z) + F₁(y).z ] + F₁(x).y.z
#
# ...
#
# Then after it's a 'piece of cake' finding Fᵪ (∀ χ ∈ ℕ*)
#
# reminders : F₁(x) with x = Pⁿ (P ∈ { Primes > 2 } )
#             F₁(x)   = Pⁿ    \(P-1)
#             F₁(x+1) = P⁽ⁿ⁺¹⁾\(P-1)
#
#             if P=2 then F₁(x) = 2ⁿ-1
#             if P=2 then F₁(x) = 2⁽ⁿ⁺¹⁾-1
#
#  And P₁ⁿ > P₂ⁿ > ... > Pᵪⁿ (∀n = r,s,t,..,k)  [cond.1]
#
# Now actually I dont see any objection for
# converting previous equations with xᵪ = Pᵪᵠ 
#                     meaning x₁=P₁ʳ ; 
#                             x₂=P₂ˢ ; (was y in F₃) 
#                             x₃=P₃ᵗ ; (was z in F₃) 
#                             ...
#                             xᵨ=Pᵨᶿ   ∀ Ρᵪ Ρrime,
#                                      ∀ θ  ∈ ℕ
#
# Take a look at my implementation above (PART III)
#   ( needs some cleanings but works !!! )
#
#########################################################
# Maths is a never-ending story.. =
#=================================


#===================================================
################### PART II ###( ∃υρεΚα 2 ) ########
#===================================================

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
    #Sn["$P"]+="$P_n "

    # board effect !!
    #  ( this function is not 
    #    supposed to return this )
    #
    #echo P_n $P_n

    recure_S_Pn "$P" "$((n-1))"
  else
      sum+="$(($1+1))"
      #Sn["$P"]+="$1 1"
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

    #          vv *Not* vv same shell => 2d call
    S_Pn[i]="$(recure_S_Pn "${Pn[i]}" "${En[i]}")"
    
    printf2 "S_Pn :" "${S_Pn[@]}"
    printf2 "Pn :" "${Pn[@]}"
    printf2 "En :" "${En[@]}"

    ((i++))
done 

}

Main () {

  [[ "$1" -eq 1 ]] && Result=0 && End "$Result" "$1"

  declare -i recurent=1 result=0 N="$1" sum=0
  declare -a S_Pn=() Pn=() En=()
  #declare -A Sn=()  # to be exported ?!..
  #                  # (see recure fct )

# Board effects (Sn) !
#recure_S_Pn 2 10 1
#printf  "S 2^3 : \n"
#recure_S_Pn 3 1

  recurent_Deb "$@"

  printf2 "Fact :" "${Fact[@]}"

  set_Pn_Sn_arrays "$@"

  [[ "${#Pn[@]}" -eq 1 ]] && \
    echo "$((S_Pn[0] - Pn[0]*En[0]))" && exit 0

  printf2 "S_Pn[1]:%s / Pn[1] :%s\n" \
          "${S_Pn[1]}" "${Pn[1]}"
  result=0

  # [3a] part of [3] (^Cf Maths^)
  #
  SP1="${S_Pn[0]}"
  SP2="$((S_Pn[1] - Pn[1]**En[1]))"

  printf2 "SP1: %s  SP2: %s\n" "$SP1" "$SP2"

  result=$((SP1*SP2))

  printf2 "result :" "$result"

  # [3b] part of [3]
  #
  SP1="$((Pn[1]**En[1]))"
  SP2="$((S_Pn[0] - Pn[0]**En[0]))"

  printf2 "SP1: %s  SP2: %s\n" "$SP1" "$SP2"

  result+=$((SP1*SP2))

  echo "$result"
}

#===================================================
################## PART I ###( Brute Force)#########
#===================================================

iterative_For_1 () {

for i in "${!Fact[@]}"
do
    result="${Fact[i]}" 
    result2="$(echo "$result" | bc)"
    opposite=$((N/result2)) 
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
        opposite=$((N/result2)) 
        result3+="$result2, $opposite] : $result"$'\n'
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

# nb: there was some bug here (Level 9) 
#      up to post Nº21 :
#
#     ie 3^8*8192 was solved wrong with
#        3^9 and ( 3^8*8192 \ 3^9 ) as wrong multiples
#     funny part it's 2d degree eq : x² - dx + n = 0 [A]
#     with d difference b3tween true result & false.
#          n the number to find multiples
#          x wrong multiples are solutions of [A] !
#
# nb':     [A] <=> d = x + n/x
#
# nb2: No more bug here 
#      so take 21th post (or before) to see it..
#
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
          [ "$m" == "$p" ] || [ "$n" == "$o" ] || \
          [ "$o" == "$p" ] && break
        for q in "${!Fact[@]}" ; do
          [ "$i" == "$q" ] || [ "$j" == "$q" ] || \
          [ "$k" == "$q" ] || [ "$l" == "$q" ] || \
          [ "$m" == "$q" ] || [ "$n" == "$q" ] || \
          [ "$o" == "$q" ] || [ "$p" == "$q" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}*${Fact[p]}*${Fact[q]}"
          result2="$(echo "$result" | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
  done ; done
fi
x9_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"
}


sum_Factors () {

# Sample of nameref var
#  in 'for' loop line 752
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

        [[ $M -ne $N ]] && sum_2+=$((2**13 + 1)) #\
        #&& [[ $Once -eq 1 ]] && Once=0
      
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
# Maths ! # rectified a huge difference '/' means '\'
###########
# Simplier should be using S(2ⁿ) = 2ⁿ - 1
#       or should be using S(3ⁿ) = 3ⁿ / 2             2 
#       or should be using S(5ⁿ) = 5ⁿ / 2²            4
#       or should be using S(7ⁿ) = 7ⁿ / (3*2)         6
#       or should be using S(11ⁿ) = (11ⁿ-1) / (5*2)  10
#       or should be using S(13ⁿ) = (13ⁿ) / (3*2²)   12
#       or should be using S(17ⁿ) = (17ⁿ) / (2⁴)     16
#       or should be using S(19ⁿ) = (19ⁿ) / (2*3²)   18
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#       or ... Eurèka !!!
#
#            ! This is integer division ! v       (!!!)
#                                         |
#       or should be using   S(Pⁿ) = (Pⁿ) \ (P-1) (!!) 
#                            ⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻⁻ 
# => All atomic numbers // N = Pⁿ are deficients (P prime)
#
# (!!!) : Means a lot and particularly S₁(P₁ⁿ) cant be
#          reduced using 'classical' arithmetic props.
#   ((New branch ?! :
#      What other forms/equations/problems
#      could perform in ℕ [+,*,\] 
#      and are wrong in ℕ [+,*] - old fashinoned ℕ it is))
#
# Jumping straight-forward..
#     (with P₁ P₂ primes ; P₁>P₂) to :
#
#      S₂(P₁ʳ.P₂ˢ) = S₁(P₁ʳ⁺¹).S₁(P₂ˢ)
#                  + S₁(P₁ʳ)  .P₂ˢ           [th.1]
#
# let: P₂ˢ = S₁(P₂ˢ).(P₂ - 1) [remainer P₁ > P₂]
#
#      S₂(P₁ʳ.P₂ˢ) = S₁(P₁ʳ⁺¹).S₁(P₂ˢ)            
#                  + S₁(P₁ʳ)  .S₁(P₂ˢ).(P₂ - 1)  =>false!
#
#  So : S₁(P₂ˢ).(P₂ - 1) ≠ P₂ˢ : We deal with '\' not '/' !
#
#  NB : S₂(P₁ʳ.P₂ˢ) formula or [th.1]
#                   is true if and only if :
#
#         P₁ʳ > P₂ˢ   ( => P₁ < P₂ can occurs.. )
#
#      and by definition of S(N) (recursive!) 
#      when N=Pⁿ (P prime)
#          S(Pⁿ) = Pⁿ⁻¹ + Pⁿ⁻² +..+ P¹ + P⁰  (!)
#
# ================================================
# TODO: This solution needs more maths into it ! #
##################################################

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

  # Trivial cases
  [[ "$N" -eq 2 ]] && echo "deficient" && exit 0
  [[ "$N" -eq 1 ]] && echo "deficient" && exit 0

  N=${N:=$((5*7*11*13*17*19))}

  #echo $Two_s ${Fact_R[0]} && exit

  # Force YES recurence (Actually 28 fails recurencelly)
  # rem : should create same for 3ⁿ and 5ⁿ and 7ⁿ and Pⁿ
  #  nb : must force no fast mode too if N=P₁ʳ.P₂ˢ
  #
  [ "$4" == "R" ] || [[ $((N % 256)) -eq 0 ]] \
    && recurent=1 # && \

  # Force NO recurence except if very much too loooooong
  #      ( recurence is enabled if N % 256 = 0 see above )
  #      (        reason : iterative gets very slow then )
  #  nb : must force no fast mode too if N=P₁ʳ.P₂ˢ
  # 
  [ "$4" == "r" ] \
    && recurent=0
  
  recurent_Deb2 "$@"

  # N is prime
  [[ "$N" -eq "${Fact_R[0]}" ]] && echo "deficient" \
                                && exit 0

  [[ "${Fact_R[0]}" =~ '^' ]] && \
  [[ "$(bc <<<"${Fact_R[0]}")" -eq "$N" ]] && \
  [[ "$recurent" -eq 1 ]] && \
  Two_s=1

     printf2 "Fact_R[@] :" "${Fact_R[@]}" 
     printf2 "Fact_R[0] :" "${Fact_R[0]}" 
     printf2 "#Fact_R[@] :" "${#Fact_R[@]}" 
     # Surprise
     printf2 "\$2:=%s=\n" "$2"
     printf2 "\$4:=%s=\n" "$4"

     # By default all N=P₁ʳ.P₂ˢ [3]
     #   can be solved by fast algorithm
     #  ( forced slow mode is when $2 = 'o' )
     #
     if [ "$No_Fast" != 'o' ]  && \
        [[ "${#Fact_R[@]}" -ge 2 ]]
     then
        # Fast algorithm ( n=2 )
        #Result=$("./$0" "$N" 1)
        # Better algorithm ! ( 2 -> n )
        Result=$("./$0" "$N" 0 2)
        :
        End "$Result" "$N"
     fi

     if [ "$No_Fast" != 'o' ]  && \
        [[ "${#Fact_R[@]}" -eq 1 ]]
     then
        # Fast algorithm
        Result=$("./$0" "$N" 0 1)
        :
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
declare -i middle=1 opposite=2 Fact_nb=1
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

   # For 9x iterations defined above
   #
   for iterat in iterative_For_{1..9}
   do
     "$iterat"

     result3=""
     opposite=0
   done

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

  No_Fast="$2"

  get_Factors "$@"

  End "$Result" "$1"

}

declare -i Prev_F Result_Fn P_prev E_Prev

case "$2" in
  0)
    Main_Atom "$@"
    ;;
  1) 
    Main "$@"
    ;;
  *)
    main "$@"
    ;;
esac

# DR -- Very Challeng\ng ! --
#
# ~/.../bash/perfect-numbers $ time ./no-skip.bats
# no-skip.bats
#  ✓ Smallest perfect number is classified correctly
#  ✓ Medium perfect number is classified correctly
#  ✓ Large perfect number is classified correctly
#  ✓ Smallest abundant number is classified correctly
#  ✓ Medium abundant number is classified correctly
#  ✓ Large abundant number is classified correctly
#  ✓ Smallest prime deficient number is classified correctly
#  ✓ Smallest non-prime deficient number is classified correctly
#  ✓ Medium deficient number is classified correctly
#  ✓ Large deficient number is classified correctly
#  ✓ Edge case (no factors other than itself) is classified correctly
#  ✓ Zero is rejected (not a natural number)
# ✓ Negative integer is rejected (not a natural number)
#
#13 tests, 0 failures

#real    0m5.001s
#user    0m3.392s
#sys     0m2.212s

# DR - Ascension 2025 +145 days... 
