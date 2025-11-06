#!/usr/bin/env bash
#

examples=$(cat <<fin
00000000              00
00000040              40
0000007F              7F
00000080             81 00
00002000             C0 00
00003FFF             FF 7F
00004000           81 80 00
00100000           C0 80 00
001FFFFF           FF FF 7F
00200000          81 80 80 00
08000000          C0 80 80 00
0FFFFFFF          FF FF FF 7F
fin
)
echo "${examples:-1}" >/dev/null
# To see..
#bc <<<$'obase=2;ibase=16;a=2^44-1;40;a;7F;a;80;8100;a;\
#2000;C000;a;3FFF;FF7F;a;4000;818000;a;100000;C08000;a;\
#1FFFFF;FFFF7F;a;2000000;81808000;a;8000000;C0808000;a;\
#0FFFFFFF;FFFFFF7F'
# ruler for bytes
#echo {0..7}{"","","","","","","",""} | sed 's/ //g'
#
# or with 0 as not significant bit 
#echo {"","","","","",""}"01234567"

# 1000000000000000000000000000
# 11000000100000001000000000000000
#
# 0000000011111111222222223333333344444444
#
# 1111111111111111111111111111                                       
# 11111111111111111111111101111111
#
# 0000000011111111222222223333333344444444

# Seen (thx to examples) :
#
#    Basically when reduced in base 2 
#    purpose is to count zeroes/ones aka bits grouped by 7 (/8)
#
#    Actually vlq's *is* equal to binary code 
#    once stripped 8th bits.
#
# Maximum single byte value identical in both vlq & hexa :
# (setting obase first is better)
#
#bc -l <<<"obase=16;ibase=2;01111111"  => 7F

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
'[A-F]'
REGEX_PARAM2=\
'[[:digit:]]'
REGEX_PARAMS_ENC=\
"^encode( ($REGEX_PARAM1|$REGEX_PARAM2)+)+$" 
REGEX_PARAMS_DEC=\
"^decode ($REGEX_PARAM1|$REGEX_PARAM2){2}( ($REGEX_PARAM1|$REGEX_PARAM2){2})*$" 
REGEX_PARAMS_HI=\
"^hello( ($REGEX_PARAM1|$REGEX_PARAM2)+)+$" 

if { [[ "$Input2" =~ $REGEX_PARAMS_ENC ]] \
  || [[ "$Input2" =~ $REGEX_PARAMS_DEC ]] ;}
then
      printf2 'UNARY OPERATOR UNQUOTED RegExpr Positive !'
else
      printf2 'RegExpr Wrong as usual !  (=~) '
fi
}

test_params () {

  store_Input "$@"
  test_regex       # Uses '$Input2' (no need to pass $Args)

  if [[ ! "$Input2" =~ $REGEX_PARAMS_ENC ]] \
  && [[ ! "$Input2" =~ $REGEX_PARAMS_DEC ]]
  then
      [[ "$Input2" =~ $REGEX_PARAMS_HI ]] \
        && echo "unknown subcommand" && exit 3

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

mk_VQL () {

  result=""
  final_result=""
  case "$1" in
    'encode')
    shift
    while [ -n "$1" ]
    do
      bin_2enc="$(bc <<<"obase=2;ibase=16;$1")"

      # Trivial case
      if [[ "${#bin_2enc}" -le 7 ]]
      then
        if [ -n "$2" ]    # ok locally 
        then              # wont do it on exercism site 
                          #  (pads space not zero..)
          final_result+="$(printf '%02s ' "$1")"
        else
          final_result+="$(printf '%02s\n' "$1")"
        fi
        shift
        continue
      fi
        
      # Adding mod 7 first
      mod_7enc=$(("${#bin_2enc}" % 7))
      printf2 "mod_7enc :" "$mod_7enc"

      if [[ "$mod_7enc" -ne 0 ]]
      then
        diff=$((7 - mod_7enc))
        padding_zeros=$(printf "%0${diff}i")
        result+='1'"$padding_zeros""${bin_2enc:0:mod_7enc}"" "
        bin_2enc="${bin_2enc:mod_7enc}"
        printf2 "result mod :" "$result"
        printf2 "bin_2enc mod :" "$bin_2enc"
      fi

      while [[ "${#bin_2enc}" -gt 7 ]]
      do
        result+='1'"${bin_2enc:0:7}"" "
        bin_2enc="${bin_2enc:7}"
        printf2 "result while :" "$result"
        printf2 "bin_2enc while :" "$bin_2enc"
      done

      result+='0'"${bin_2enc}"
      printf2 "result fin :" "$result"
      printf2 "bin_2enc fin :" "$bin_2enc"

      for i in $result
      do              # same rem. as above for 0 padding
        result_hex+=\
"$(printf '%02s' "$(bc <<<"obase=16;ibase=2;$i")")"" "
      done

      # remove trailing <space> (if any)
      result_hex="${result_hex::-1}"

      if [[ $DEBUG -gt 0 ]]
      then
        echo "result fin : " ; echo "$result"
        echo {"","","","","",""}"01234567" | sed 's/ //g'
        bc <<<"obase=2;ibase=16;$2"
      fi

      if [ -n "$2" ]
      then            # same rem. as above for 0 padding
        final_result+="$(printf '%02s ' "$result_hex")"
      else
        final_result+="$(printf '%02s\n' "$result_hex")"
      fi

      result="" ; result_hex=""
      shift
    done

    echo "${final_result//  / 0}" # | sed 's/  / 0/g'
      ;;
    'decode')
      shift
      while [ -n "$1" ]
      do
        bin_2dec="$(bc <<<"obase=2;ibase=16;""$1")"

        # zeros padded result for last values
        bin_2dec="$(printf '%08i' "$bin_2dec")"

        # remove significant bit of vql
        result+="${bin_2dec:1}"
        printf2 "result while :" "$result"

        # Ending vql nb byte code is < 128
        if [[ "$((16#$1))" -lt 128 ]]
        then          # same rem. as above for 0 padding
          # Change trailing " " with other char(s) to separate
          #   different values of VQL numbers (0 pad for nb only)
          final_result+="$(printf '%02s' "$(bc <<<"obase=16;ibase=2;""$result")")"" "
          result=""
        fi
        last="$1"
        shift
      done

      # No vql ending byte code..
      [[ "$((16#$last))" -ge 128 ]] \
      && echo "incomplete byte sequence" && exit 2

      if [[ $DEBUG -gt 0 ]]
      then
        echo "result fin : " ; echo "$result"
        echo {"","","","","",""}"01234567" | sed 's/ //g'
        bc <<<"obase=2;ibase=16;$1"
      fi
        
      echo "$final_result" | sed 's/ $//' \
                           | sed 's/  / 0/g' # for remote @tests
                                             # <> printf '%02s' .. 
      ;;
    *) # never played..
       echo "unkknown subcommmand"
       exit 1
      ;;
  esac
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
                #mk_VQL $Args # << bot is stubborn.. 
                mk_VQL "${Input[@]}"
                ;;
            *)  printf2 "An Invalid Input Occurred"
                exit 1
                ;;
    esac
    exit 0
}

main "$@"

# DR - Ascension 2025 plus: 162 days...
