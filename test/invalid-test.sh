#!/bin/sh

cd ${0%/*}

# make test output TAP compatible
# https://en.wikipedia.org/wiki/Test_Anything_Protocol

fails=0
tests=`ls invalid/* | wc -l`

echo "1..${tests##* }"
for input in invalid/*
do
  i=$((i+1))
  if ../json.ksh < "$input" > /tmp/json.ksh_outlog 2> /tmp/json.ksh_errlog
  then
    echo "not okay $i; cat $input | ../json.ksh should fail"
    #this should be indented with '#' at the start.
    echo "OUTPUT WAS >>>"
    cat /tmp/json.ksh_outlog
    echo "<<<"
    fails=$((fails+1))
  else
    echo "okay $i; $input was rejected"
    echo "#" `cat /tmp/json.ksh_errlog`
  fi
done
echo "$fails test(s) failed"
exit $fails
