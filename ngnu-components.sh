#!/bin/bash
function gngnu_ver {
	if [[ "$1" == "libpipeline" ]]; then
		URL="https://gitlab.com/libpipeline/libpipeline.git"
	else
		URL="https://https.git.savannah.nongnu.org/git/$1.git"
	fi
	timeout 5 git ls-remote --tags --refs $URL 2>/dev/null \
	| cut -d '/' -f 3 | sed -E 's/^[vVrR]//' \
	| grep -viE "alpha|beta|rc|dev|snapshot|init" \
	| grep -E '^[0-9]+(\.[0-9]+)+$' | sort -V | tail -n 1
}

function wngnu_ver {
	local URL="https://download.savannah.nongnu.org/releases/$1/"
	wget -T 5 -t 1 -cqO- "$URL" 2>/dev/null \
	| grep -oE "$1-[0-9]+(\.[0-9]+)+(\.tar\.[a-z0-9]+|\.src\.tar\.gz|\.zip)" \
	| sed -E "s/$1-([0-9]+(\.[0-9]+)+).*/\1/" | sort -V | tail -n 1
}