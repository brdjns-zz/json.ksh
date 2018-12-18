#!/bin/sh

cd ${0%/*}
tmp=${TEMP:-/tmp}
tmp=${tmp%%/}/    # avoid duplicate //

fails=0
i=0
tests=`ls valid/*.json | wc -l`
echo "1..$tests"
for input in valid/*.json
do
  input_file=${input##*/}
  expected="${tmp}${input_file%.json}.no-head"
  egrep -v '^\[]' < ${input%.json}.parsed > $expected
  i=$((i+1))
  if ! ../json.ksh -n < "$input" | diff -u - "$expected"
  then
    echo "not okay $i; $input"
    fails=$((fails+1))
  else
    echo "okay $i; $input"
  fi
done
echo "$fails test(s) failed"
exit $fails
