#!/bin/sh

cd ${0%/*}

# can't detect sourcing in sh, so immediately terminate the attempt to
# parse
. ../json.ksh </dev/null

ptest () {
  tokenise | parse >/dev/null
}

fails=0
i=0
echo "1..4"
for input in '"oooo"  ' '[true, 1, [0, {}]]  ' '{"true": 1}'
do
  i=$((i+1))
  if echo "$input" | ptest
  then
    echo "okay $i - $input"
  else
    echo "not okay $i - $input"
    fails=$((fails+1))
  fi
done

if ! ptest < ../package.json
then
  echo "not okay 4; parsing package.json failed!"
  fails=$((fails+1))
else
  echo "okay $i; package.json"
fi

echo "$fails test(s) failed"
exit $fails
