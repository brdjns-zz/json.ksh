#!/bin/sh

cd ${0%/*}

# all capitals for variable names is insane
input=./solidus/string_with_solidus.json
output_escaped=./solidus/string_with_solidus.with-escaping.parsed
output_without_escaping=./solidus/string_with_solidus.no-escaping.parsed

fails=0

echo "1..2"

if ! ../json.ksh < $input| diff -u - ${output_escaped}; then
  echo "not okay; json.ksh run without -s option should leave solidus escaping intact"
  fails=$((fails + 1))
else
  echo "okay $i; solidus escaping was left intact"
fi

if ! ../json.ksh -s < $input| diff -u - ${output_without_escaping}; then
  echo "not okay; json.ksh run with -s option should remove solidus escaping"
  fails=$((fails+1))
else
  echo "okay $i; solidus escaping has been removed"
fi

echo "$fails test(s) failed"
exit $fails
