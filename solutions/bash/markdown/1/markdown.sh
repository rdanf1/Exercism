#!/usr/bin/env bash
#

line_EMs () {
    # With == as unary op ( as with =~ & regex )
    #  right part is pattern to match
    
    while [[ "$line" == *_*?_* ]]
    do
      one=${line#*_}
      two=${one#*_}
      if [ ${#two} -lt ${#one} ] \
        && [ ${#one} -lt ${#line} ]
      then
        line="${line%%_$one}<em>${one%%_$two}</em>$two"
      fi 
    done
      
    # Or a concise way to do it..
    #  ( was near actual line 102 )
    #line=$(echo "$line" | sed -E 's:_([^_]+)_:<em>\1</em>:g')
  }

line_STRONGs () {

  while true
  do
    orig="$line"
    if [[ "$line" =~ ^(.+)__(.*) ]]
    then
      # From above matching with =~ 
      #  (explanations are in 'man bash'
      #      & search for '=~' )
      #
      # gets/matches   (.+) and                (.*)
      #   values
      #
      pre=${BASH_REMATCH[1]};post=${BASH_REMATCH[2]}
      # Finds first occurence of __
      if [[ "$pre" =~ ^(.*)__(.+) ]]
      then
        printf -v line "%s<strong>%s</strong>%s" \
                       "${BASH_REMATCH[1]}"  \
                       "${BASH_REMATCH[2]}"  "$post"
      fi
    fi
    [ "$line" != "$orig" ] || break
  done
}

line_HEADs () {

      line_EMs

      # n is number of '#'
      #      ( between 1 up to 6 )
      #
      HEAD=${line:n}
      while [[ $HEAD == " "* ]]
      do 
        HEAD=${HEAD# }
      done
      
      h="$h<h$n>$HEAD</h$n>"
}

main () {

# h is line translated or
#   partially translated to markdown
# line is same though from input..
#
h="" ; line=""

while read -r line
do

  # __.*__ patterns goes first..
  #
  line_STRONGs

  # "*<space>" is required for a list
  #echo "$line" | grep '^\* ' > /dev/null 2>&1
  #if [ $? -eq 0 ]
  #
  # not so clear though..
  #
  if [[ "$line" =~ ^\*\  ]]
  then
    # Inside a list
    #
    if [ "$inside_a_list" != 'yes' ]
    then
      h="$h<ul>"
      inside_a_list='yes'
    fi

    line_EMs

    # removes "* " at beginning of
    #   list line, translate it
    #
    h="$h<li>${line#? }</li>"

  else
    # Outside a list
    #
    if [ "$inside_a_list" == 'yes' ]
    then
        h="$h</ul>"
        inside_a_list='no'
    fi

    # Check if Header
    #
    n="$(expr "$line" : "#\{1,\}")"
    if [ "$n" -gt 0 -a 7 -gt "$n" ]
    then

      line_HEADs

    else
      # totally useless..
      #grep '_..*_' <<<"$line" > /dev/null # &&

      line_EMs

      h="$h<p>$line</p>"
    fi
  fi
  #
done < "$1"

# Close list eventually
#
if [ "$inside_a_list" == 'yes' ]
then
  h="$h</ul>"
fi

echo "$h"

}

main "$@"

