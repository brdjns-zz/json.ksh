#!/bin/sh

cd ${0%/*}
fails=0
i=0
tests=`ls valid/*.json | wc -l`
echo "1..${tests##* }"
for input in valid/*.json
do
  expected="${input%.json}.parsed"
  i=$((i+1))
  if ! ../json.ksh < "$input" | diff -u - "$expected"
  then
    echo "not okay $i; $input"
    fails=$((fails+1))
  else
    echo "okay $i; $input"
  fi
done
echo "$fails test(s) failed"
exit $fails
