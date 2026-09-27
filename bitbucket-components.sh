#!/bin/bash
function gbb_ver {
	local repo=$1
	local name=$2
	timeout 5 git ls-remote --tags --refs https://bitbucket.org/$repo.git \
	| grep -oE 'tags/([v]*[0-9.][^"]*|'"$name"'-[0-9]+\.[0-9]+\.[0-9]+)' \
	| grep -vi "alpha\|beta\|rc" | sed -E 's|tags/[a-z-]*||g' | sort -V \
	| tail -n 1
}