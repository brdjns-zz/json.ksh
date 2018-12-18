#!/usr/bin/env ksh
# json.ksh: kornshell json parser
# copyright 2018 bradley jones

# exception handling
function die {
	print "$*" >&2
	exit 1
}

# defaults
brief=0
leafonly=0
prune=0
no_head=0
normalise_solidus=0

function usage {
	cat 1>&2 <<EOF
Usage: $0 [-b] [-l] [-p] [-s] [-h]
-p   prune empty; exclude fields with empty values
-l   leaf only; show only leaf nodes, which stops data duplication
-b   brief; combine 'leaf only' and 'prune empty' options
-n   no-head; do not show nodes without a path (lines starting with '[]')
-s   remove escaping of the solidus
-h   show this usage
EOF
}

function parse_options {
	while getopts ":hblpns" option
	do
		case $option in
			h) usage; exit 0;;
			b) brief=1;leafonly=1;prune=1;;
			l) leafonly=1;;
			p) prune=1;;
			n) no_head=1;;
			s) normalise_solidus=1;;
			:) die "option -$OPTARG requires an argument";;
			*) die "unknown option";;
		esac
	done
	shift $((OPTIND-1))
	OPTIND=1
}

function awk_egrep {
	local pattern_string=$1

	awk '{
    while ($0) {
      start=match($0, pattern);
      token=substr($0, start, rlength);
      print token;
      $0=substr($0, start+rlength);
    }
  }' pattern="$pattern_string"
}

function tokenise {
	local grep
	local escape
	local char

	if print "test string" | egrep -ao --color=never "test" >/dev/null 2>&1
	then
		grep='egrep -ao --color=never'
	else
		grep='egrep -ao'
	fi

	if print "test string" | egrep -o "test" >/dev/null 2>&1
	then
		escape='(\\[^u[:cntrl:]]|\\u[0-9a-fa-f]{4})'
		char='[^[:cntrl:]"\\]'
	else
		grep=awk_egrep
		escape='(\\\\[^u[:cntrl:]]|\\u[0-9a-fa-f]{4})'
		char='[^[:cntrl:]"\\\\]'
	fi

	local string="\"$char*($escape$char*)*\""
	local number='-?(0|[1-9][0-9]*)([.][0-9]*)?([ee][+-]?[0-9]*)?'
	local keyword='null|false|true'
	local space='[[:space:]]+'

	# force zsh to expand $a into multiple words
	local is_word_split_disabled

	is_word_split_disabled=$(unsetopt 2>/dev/null | grep -c '^shwordsplit$')

	[[ "$is_word_split_disabled" != 0 ]] && setopt shwordsplit

	$grep "$string|$number|$keyword|$space|." | egrep -v "^$space$"

	[[ "$is_word_split_disabled" != 0 ]] && unsetopt shwordsplit
}

function parse_array {
	local index=0
	local ary=''
	read -r token
	case "$token" in
		']') ;;
		  *)
			while :
			do
				parse_value "$1" "$index"
				index=$((index+1))
				ary="$ary""$value"
				read -r token
				case "$token" in
					']') break ;;
					',') ary="$ary," ;;
					  *) die "expected , or ]; got ${token:-eof}" ;;
				esac
				read -r token
			done
			;;
	esac
	[[ "$brief" -eq 0 ]] && value=$(printf '[%s]' "$ary") || value=
	:
}

function parse_object {
	local key
	local obj=''
	read -r token
	case "$token" in
		'}') ;;
		  *)
			while :
			do
				case "$token" in
					'"'*'"') key=$token ;;
					      *) die "expected string got ${token:-eof}" ;;
				esac
				read -r token
				case "$token" in
					':') ;;
					  *) die "expected : got ${token:-eof}" ;;
				esac
				read -r token
				parse_value "$1" "$key"
				obj="$obj$key:$value"
				read -r token
				case "$token" in
					'}') break ;;
					',') obj="$obj," ;;
					  *) die "expected , or } got ${token:-eof}" ;;
				esac
				read -r token
			done
			;;
	esac
	[ "$brief" -eq 0 ] && value=$(printf '{%s}' "$obj") || value=
	:
}

function parse_value {
	local jpath="${1:+$1,}$2" isleaf=0 isempty=0 print=0
	case "$token" in
		'{') parse_object "$jpath";;
		'[') parse_array  "$jpath";;
		# at this point, the only valid single-character tokens are digits.
		''|[!0-9]) die "expected value got ${token:-eof}";;
		  *) value=$token
			 # if asked, replace solidus ("\/") in json strings with normalised value: "/"
			 [[ "$normalise_solidus" -eq 1 ]] \
				 && value=$(print "$value" | sed 's#\\/#/#g'); isleaf=1
			 [[ "$value" = '""' ]] && isempty=1;;
	esac
	[[ "$value" = '' ]] && return
	[[ "$no_head" -eq 1 ]] && [[ -z "$jpath" ]] && return
	[[ "$leafonly" -eq 0 ]] && [[ "$prune" -eq 0 ]] && print=1
	[[ "$leafonly" -eq 1 ]] && [[ "$isleaf" -eq 1 ]] \
		&& [[ $prune -eq 0 ]] && print=1
	[[ "$leafonly" -eq 0 ]] && [[ "$prune" -eq 1 ]] \
		&& [[ "$isempty" -eq 0 ]] && print=1
	[[ "$leafonly" -eq 1 ]] && [[ "$isleaf" -eq 1 ]] && \
		[[ $prune -eq 1 ]] && [[ $isempty -eq 0 ]] && print=1
	 [[ "$print" -eq 1 ]] && printf "[%s]\t%s\n" "$jpath" "$value"
	:
}

function parse {
	read -r token
	parse_value
	read -r token
	case "$token" in
		'') ;;
	     *) die "expected eof; got $token" ;;
	esac
}

if ([[ "$0" = "$ksh_source" ]] || ! [[ -n "$ksh_source" ]]); then
	parse_options "$@"
	tokenise | parse
fi
