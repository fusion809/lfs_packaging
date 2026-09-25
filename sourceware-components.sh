#!/bin/bash
function gsw_ver {
	local URL="https://sourceware.org/git/$1.git"
	timeout 5 git ls-remote --tags --refs "$URL" \
	| grep -oEi "$1[_-]*[0-9_.]+" | sed -E 's/^[A-Za-z0-9]+[_-]//g' \
	| tr '_' '.' | sort -V | tail -n 1
}

function wsw_ver {
	wget -cqO- -T 5 -t 1 "https://sourceware.org/pub/$1/" \
	| grep "$1-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed "s/$1-//g" | sort -V \
	| tail -n 1
}
