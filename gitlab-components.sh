#!/bin/bash
function gll_ver {
	local URL="https://gitlab.com/$1.git"
	timeout 5 git ls-remote --tags --refs "$URL" 2> /dev/null \
	| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
	| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
	| grep -E "^[0-9]+(\.[0-9]+)+$" | sort -V | tail -n 1
}

function glt_ver {
	local encoded=$(echo "$1" | sed "s|/|%2F|g")
	local API="https://gitlab.com/api/v4/projects/${encoded}/repository/tags?per_page=1"
	local api_ver=$(wget -cqO- -T 5 -t 1 "$API" 2>/dev/null \
	| grep -oP '"name":"\K[^"]+' \
	| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' \
	| head -n 1)
	if [[ -n "$api_ver" ]]; then
		echo "$api_ver"
		return 0
	fi
	wget -T 5 -t 1 -cqO- https://gitlab.com/$1/-/tags \
	| grep -E "[v]*[0-9]+\.[0-9]+" | grep "^<a href=" \
	| cut -d '"' -f 2 | cut -d '/' -f 6 | grep -E "^[v]*[0-9.]+$" \
	| sed 's/^v//g' | sort -V | tail -n 1	
}