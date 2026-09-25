#!/bin/bash
GIT_TERMINAL_PROMPT=0

function fdt_ver {
    local repo=$1
	local name=$2
    if [[ $repo != "gstreamer/gstreamer" ]]; then
    	wget -T 5 -t 1 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" \
		| grep -oE 'tags/([v]*[0-9.][^"]*|'"$name"'-[0-9]+\.[0-9]+\.[0-9]+)' \
		| grep -v "\.99" | sed "s|$name-||g" | grep -vE "dev|rc|alpha|beta" \
		| sed 's|tags/||; s/^v//' | sort -V | tail -n 1
    else
    	wget -T 5 -t 1 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" \
		| grep -oE 'tags/[v0-9.][^"]*' | grep -vE "dev|rc|alpha|beta" \
		| sed 's|tags/||; s/^v//' | grep -oE "[0-9]+\.[0-9]*[02468]\.[0-9]+" \
		| sort -V | tail -n 1
    fi
}

function fver {
	# Only log as a failure when inst_ver is also unknown.
	# If inst_ver is set, upstream sources are temporarily unreachable/stale —
	# return the installed version silently rather than spamming the log.
	if [[ -z "$2" ]]; then
		echo "$(date +"%r %d/%m/%Y"), $1" >> ~/logs/failed_versioning.log
	fi
	echo "$2"
}

function gbb_ver {
	local repo=$1
	local name=$2
	timeout 5 git ls-remote --tags --refs https://bitbucket.org/$repo.git \
	| grep -oE 'tags/([v]*[0-9.][^"]*|'"$name"'-[0-9]+\.[0-9]+\.[0-9]+)' \
	| grep -vi "alpha\|beta\|rc" | sed -E 's|tags/[a-z-]*||g' | sort -V \
	| tail -n 1
}

function gfl_ver {
	if [[ -n "$2" ]]; then
		local name="$2"
	else
		local name=$(echo $1 | cut -d '/' -f 2)
	fi
	local URL="https://gitlab.freedesktop.org/$1.git"
    if [[ "$1" != "gstreamer/gstreamer" ]]; then
	    timeout 5 git ls-remote --tags "$URL" 2>/dev/null \
		| grep -oE 'tags/([v]*[0-9.][^"]*|'"$name"'-[0-9]+\.[0-9]+\.[0-9]+)' \
		| grep -v "\.99" | sed "s|$name-||g" \
		| sed -n 's|tags/v\?\([0-9][0-9.]*\)$|\1|p' \
		| grep -vE "dev|rc|alpha|beta" | sort -V | tail -1
    else
	    timeout 5 git ls-remote --tags "$URL" 2>/dev/null \
		| sed -n 's|.*refs/tags/v\?\([0-9][0-9.]*\)$|\1|p' \
		| grep -vE "dev|rc|alpha|beta" \
		| grep -oE "[0-9]+\.[0-9]*[02468]\.[0-9]+" | sort -V \
		| tail -1
    fi

}

function gglpk_ver {
	local URL="https://salsa.debian.org/science-team/glpk.git"
    timeout 5 git ls-remote --tags --refs $URL 2>/dev/null | grep "upstream" \
	| cut -d '/' -f 4 | sort -V | tail -n 1
}

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

function gsp_ver {
	local URL="https://gitlab.freedesktop.org/$1.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" \
	| sed -E 's|[a-z_-]+||g' | sort -V | tail -n 1
}

function gsw_ver {
	local URL="https://sourceware.org/git/$1.git"
	timeout 5 git ls-remote --tags --refs "$URL" \
	| grep -oEi "$1[_-]*[0-9_.]+" | sed -E 's/^[A-Za-z0-9]+[_-]//g' \
	| tr '_' '.' | sort -V | tail -n 1
}

function gxfd_ver {
	local URL="https://gitlab.freedesktop.org/xorg/$1/$2.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| grep "$2-" -i | sed -E "s/.*$2[-_]+//g" | tr '_' '.' | sort -V \
	| tail -n 1
}

function wngnu_ver {
	local URL="https://download.savannah.nongnu.org/releases/$1/"
	wget -T 5 -t 1 -cqO- "$URL" 2>/dev/null \
	| grep -oE "$1-[0-9]+(\.[0-9]+)+(\.tar\.[a-z0-9]+|\.src\.tar\.gz|\.zip)" \
	| sed -E "s/$1-([0-9]+(\.[0-9]+)+).*/\1/" | sort -V | tail -n 1
}

function wsf_ver {
    wget -T 5 -t 1 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ \
	| grep -oE "ci/[v]*[0-9]+\.[0-9]+\.[0-9]+" | cut -d '/' -f 2 \
	| sed 's/v//g' | tail -n 1
}

function wsp_ver {
	local repo_url=$(echo $1 | sed "s|/|%2F|g")
	local URL="https://gitlab.freedesktop.org/api/v4/projects/${repo_url}/releases?per_page=1"
    wget -T 5 -t 1 -cqO- "$URL" | grep -o '"tag_name":"[^"]*"' \
	| grep -v "server" | sed -E 's|[a-z_-]+||g' | head -n 1 | cut -d '"' -f4
}

function wsw_ver {
	wget -cqO- -T 5 -t 1 "https://sourceware.org/pub/$1/" \
	| grep "$1-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed "s/$1-//g" | sort -V \
	| tail -n 1
}

function wxfd_ver {
    wget -T 5 -t 1 -cqO- https://xorg.freedesktop.org/archive/individual/$1/ \
	| grep "$2-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | sed "s/$2-//g" 
	| sed 's/.tar.*$//g' | sort -V | tail -n 1
}

function wxcb_ver {
	wget -T 5 -t 1 -cqO- https://xorg.freedesktop.org/archive/individual/lib/ \
	| grep "$1-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed "s/$1-//g" | sort -V \
	| tail -n 1
}
