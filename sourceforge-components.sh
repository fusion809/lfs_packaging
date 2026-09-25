#!/bin/bash
function gsf_ver {
	if [[ "$1" == "e2fsprogs/e2fsprogs" ]]; then
		local URL="https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"
	else
		local URL="https://git.code.sf.net/p/$1.git"
	fi
	local name=$(echo $1 | cut -d '/' -f 1)
    timeout 5 git ls-remote --tags --refs $URL 2>/dev/null \
	| grep -E "tags/(v?[0-9.]+|${name}-[0-9.]+)" | sed "s/$name-//g" \
	| cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1
}

function wsf_ver {
    wget -T 5 -t 1 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ \
	| grep -oE "ci/[v]*[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 2 \
	| sed 's/v//g' | tail -n 1
}