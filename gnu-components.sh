#!/bin/bash
function ggcc_ver {
	local URL="https://gitlab.com/gnutools/gcc.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| grep -oE "releases/gcc-[0-9]+\.[0-9]+\.[0-9]+" | sed "s|releases/gcc-||" \
	| sort -V | tail -n 1
}

function ggrub_ver {
	local URL="https://gitlab.freedesktop.org/gnu-grub/grub.git"
	timeout 5 git ls-remote --tags --refs "$URL" \
	| grep -E "grub-[0-9]+\.[0-9]+$" | cut -d '-' -f 2 | sort -V | tail -n 1
}

function ggnu_ver {
    local name=$1
    if [[ "$name" == "octave" ]]; then
		echo $(goct_ver)
        return 0;
	elif [[ "$name" == "libtool" ]]; then
	    echo $(glib_ver)
        return 0;
	elif [[ "$name" == "gcc" ]]; then
	    echo $(ggcc_ver)
	    return 0;
    elif [[ "$name" == "grub" ]]; then
		echo $(ggrub_ver)
		return 0;
    elif [[ "$name" == "libtasn1" ]]; then
	    gl_ver gnutls/libtasn1
	    return 0;
    elif [[ "$name" == "libunistring" ]]; then
		local URL="https://https.git.savannah.gnu.org/git/libunistring.git"
	    timeout 5 git ls-remote --tags --refs "$URL" \
		| grep "refs/tags/v[0-9.]+" -oE | sed 's/.*v//g' | sort -V | tail -n 1
	    return 0;
    elif [[ "$name" == "nettle" ]]; then
		local URL="https://git.lysator.liu.se/nettle/nettle.git"
	    timeout 5 git ls-remote --tags --refs "$URL" \
		| grep "refs/tags/nettle_[0-9.]+_release" -oE | cut -d '_' -f 2 \
		| sort -V | tail -n 1
	    return 0;
    else
		local URL="https://https.git.savannah.gnu.org/git/$name.git"
        timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | sed -E "s/^(${name}|release)[-_]//; s/^[vVrR]//" \
		| grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | sort -V | tail -n 1
        return 0;
	fi
}

function glib_ver {
	local URL="git://git.savannah.gnu.org/libtool.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1
}

function wgnu_ver {
    wget -cqO- -T 5 -t 1 "https://ftp.gnu.org/gnu/$1/" 2>/dev/null \
	| sed -nE "s/.*href=[\"\x27]?$1-([0-9]+(\.[0-9]+)*)(\/|\.tar\.[a-z0-9]+|\.zip)[\"\x27]?.*/\1/p" \
	| sort -V | tail -n 1
}