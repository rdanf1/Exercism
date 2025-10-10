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

get_Factors () {

  REG_DIG='^[[:digit:]]+$'
  [[ "$1" -lt 1 ]] || [[ ! "$1" =~ $REG_DIG ]] && \
  echo  "Classification is only possible for natural numbers." \
  && exit 1

  declare -i N=$1

  #[[ "$N" -eq 2 ]] && echo "deficient" && exit 0


  #N=$((2*3*5*7*11*13*17*19))
  #N=$((3*5*7*11*13*17*19))
  N=${N:=$((5*7*11*13*17*19))}
  #N=$((2*2*2*2*2))

  #[ "$2" == "R" ] \
  [ "$2" == "R" ] || [[ $((N % 1024)) -eq 0 ]] \
    && recurent=1

if [[ "$recurent" -eq 1 ]]
then
    h_Option="-h"
else
    h_Option=""
fi

  #Fact=() ; for i in $(factor $N \
  Fact=() ; for i in $(factor $h_Option $N \
                     | sed 's/.*://')
            do Fact+=( $i ) ; done 
  printf2 "Fact[@]" "${Fact[@]}"

Nb_p="${#Fact[@]}"
Max_i="$((Nb_p - 1))  "
printf2 "Number  is   :" "$N"
printf2 "Factors are  :" "$(factor $N)"
printf2 "Number of factors :" "$Nb_p"
printf2 "Number of indices :" "$Max_i"

# Is wrong 
#broken=$(($Nb_p/2))

declare -i middle=1 opposite=2
for i in ${!Fact[@]}
do
  if [[ "$middle" -lt "$opposite" ]]
  then
    Fact_nb=$(bc <<<"${Fact[i]}")
    ((middle*=Fact_nb))
    opposite="$((N / middle))"
    ((broken++))
  fi
done

IFS=$'\t \n'
for primes in ${Fact[@]}
do
  #if [[ "$primes" -eq 2 ]]
  if [[ "$primes" =~ '^' ]]
  then
    printf2 "Fact : %s\n" "$primes"
  fi
done


printf2 "Level is :" "$broken"
#date "+%M:%S.%N"

# $N is Not prime..
if [[ ! "${fact[0]}" -eq "$N" ]]
then

result3=()
opposite=0

for i in ${!Fact[@]}
do
    result="${Fact[i]}" 
    result2="$(echo $result | bc)"
    opposite=$((N/result2)) 
    #result3+="$result2 : $result"$'\n' 
    result3+="$result2, $opposite] : $result"$'\n'
done

#echo "$result3" | sort -n | uniq -w "${#_}"
#x1_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
x1_res=$(echo "$result3" | sort -n)

# $N is prime..
else
  sum+=1
  return 0
fi

result3=()
opposite=0

if [[ $broken -ge 2 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    result="${Fact[i]}*${Fact[j]}" 
    result2="$(echo $result | bc)"
    opposite=$((N/result2)) 
    #result3+="$result2 : $result"$'\n' 
    result3+="$result2, $opposite] : $result"$'\n'
  done ; done
fi

#echo "$result3" | sort -n
x2_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
result3=()
opposite=0

if [[ $broken -ge 3 ]] ; then
# NB: "${!Fact[@]}" is much more faster
#                      than "$(seq ..)" (sub shell!!)
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || \
      [ "$j" == "$k" ] && break
      result="${Fact[i]}*${Fact[j]}*${Fact[k]}" 
      result2="$(echo $result | bc)"
      opposite=$((N/result2)) 
      #result3+="$result2 : $result"$'\n' 
      result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done
fi

x3_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
result3=()
opposite=0

if [[ $broken -ge 4 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        result="${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}" 
        result2="$(echo $result | bc)"
        #[[ $opposite -eq $result2 ]] && \
        #  echo ===$opposite=== && broken=1 && break 4 
        opposite=$((N/result2)) 
        result3+="$result2, $opposite] : $result"$'\n'
        #((c++))
        #[[ "$result2" -eq "3135" ]] && broken=1 \
        #  && echo c : $c && break 4
  done ; done ; done ; done
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
x4_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
result3=()
opposite=0

if [[ $broken -ge 5 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in ${!Fact[@]} ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}"
          result2="$(echo $result | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done
fi
x5_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
result3=()
opposite=0

if [[ $broken -ge 6 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in ${!Fact[@]} ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in ${!Fact[@]} ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}"
          result2="$(echo $result | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done
fi
x6_res=$(echo "$result3" | sort -n | uniq -w "${#_}")
result3=()
opposite=0

if [[ $broken -ge 7 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in ${!Fact[@]} ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in ${!Fact[@]} ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in ${!Fact[@]} ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}"
          result2="$(echo $result | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
fi
x7_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"
result3=()
opposite=0

if [[ $broken -ge 8 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in ${!Fact[@]} ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in ${!Fact[@]} ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in ${!Fact[@]} ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
        for p in ${!Fact[@]} ; do
          [ "$i" == "$p" ] || [ "$j" == "$p" ] || \
          [ "$k" == "$p" ] || [ "$l" == "$p" ] || \
          [ "$m" == "$p" ] || [ "$n" == "$o" ] || \
          [ "$o" == "$p" ] && break
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}*${Fact[p]}"
          result2="$(echo $result | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
  done 
fi
x8_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"
result3=()
opposite=0

if [[ $broken -ge 9 ]] ; then
for i in ${!Fact[@]} ; do
  for j in ${!Fact[@]} ; do
    [ "$i" == "$j" ] && break
    for k in ${!Fact[@]} ; do
      [ "$i" == "$k" ] || [ "$j" == "$k" ] && break
      for l in ${!Fact[@]} ; do
        [ "$i" == "$l" ] || [ "$j" == "$l" ] || \
        [ "$k" == "$l" ] && break
        for m in ${!Fact[@]} ; do
          [ "$i" == "$m" ] || [ "$j" == "$m" ] || \
          [ "$k" == "$m" ] || [ "$l" == "$m" ] && break
        for n in ${!Fact[@]} ; do
          [ "$i" == "$n" ] || [ "$j" == "$n" ] || \
          [ "$k" == "$n" ] || [ "$l" == "$n" ] || \
          [ "$m" == "$n" ] && break
        for o in ${!Fact[@]} ; do
          [ "$i" == "$o" ] || [ "$j" == "$o" ] || \
          [ "$k" == "$o" ] || [ "$l" == "$o" ] || \
          [ "$m" == "$o" ] || [ "$n" == "$o" ] && break
        for p in ${!Fact[@]} ; do
          [ "$i" == "$p" ] || [ "$j" == "$p" ] || \
          [ "$k" == "$p" ] || [ "$l" == "$p" ] || \
          [ "$m" == "$p" ] || [ "$n" == "$p" ] || \
          [ "$o" == "$p" ] && break
        for q in ${!Fact[@]} ; do
          [ "$i" == "$q" ] || [ "$j" == "$q" ] || \
          [ "$k" == "$q" ] || [ "$l" == "$q" ] || \
          [ "$m" == "$q" ] || [ "$n" == "$q" ] || \
          [ "$o" == "$q" ] || [ "$p" == "$q" ] || break 
          result=\
"${Fact[i]}*${Fact[j]}*${Fact[k]}*${Fact[l]}*${Fact[m]}\
*${Fact[n]}*${Fact[o]}*${Fact[p]}*${Fact[q]}"
          result2="$(echo $result | bc)"
          opposite=$((N/result2)) 
          result3+="$result2, $opposite] : $result"$'\n'
  done ; done ; done ; done ; done ; done ; done
  done ; done
fi
#echo "$result3" | sort -n | uniq -w "${#_}"
x9_res="$(echo "$result3" | sort -n | uniq -w "${#_}")"
#date "+%S.%N" && exit

# Sample of nameref var
#  in 'for' loop
#
declare -n nref
while read factor
do 
  if [[ "$factor" -eq "$N" ]]
  then
    top=1
  fi
     printf2 "adding " "$factor"
     ((sum+=factor))
     printf2 "sum is : %s // %s\n" "$sum" "$N"
done < <(for nref in x{1..9}_res
do
  while read a b
  do
    echo "${a//,/}"$'\n'"${b//] : */}"
  done < <(echo "$nref" | sed -r 's/(\*. )/\1\n/g' \
      | sed -r 's/(\*.. )/\1\n/g')
done  | sort -nur)

   printf2 "adding 1.."
   ((sum+=1))
   printf2 "sum is : %s // %s\n" "$sum" "$N"

   #date "+%M:%S.%N"

   # Peculiar case (Level=nb of prime factors..)
   #
   if [[ "$broken" -eq "${#Fact[@]}" ]]
   then
     printf2 "minus 1.."
     ((sum-=1))
     printf2 "sum is : %s // %s\n" "$sum" "$N"
   fi

   if [ "$3" == "Sub" ]
   then
     ((sum+=N))
     printf2 "plus N.. (Sub)"
     printf2 "sum is : %s // %s\n" "$sum" "$N"
   fi
   
   printf2 "sum - sum_2" "$((sum - sum_2))"

   if [[ "$recurent" -eq 1 ]]
   then
    M=$N
    while [[ "$((M % 4))" -eq 0 ]]
    do
      printf2 "%s--------%s" "$sum" "$N"

      get_Factors "$((M / 2))" "$((broken--))" "sub"

      printf2 "sum after" "$sum" 

        [[ $M -ne $N ]] && sum_2+=$((2**13 + 1)) \
        && [[ $Once -eq 1 ]] && Once=0
      
        printf2 "sum_2 :" "$sum_2"

      #((sum-=1))
      ((M/=2))
    done
      #((sum-=1))
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
   [[ $top -eq 0 ]] && Result="$((Result + N))"
   printf2 "Result :" "$Result"

}

main () {

declare -i sum=0  sum_2=0 Once=1 N=0 Result=0 top=0

#8128->6 
#for i in 33550336 
#do
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
#done
}

main "$@"

# DR -- Very Challeng\ng ! --
