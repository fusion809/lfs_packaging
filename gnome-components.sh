#!/bin/bash

function ggn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	elif [[ "$1" == "gedit" ]]; then
		URL="https://gitlab.gnome.org/World/gedit/gedit"
	elif [[ "$1" == "glib2" ]]; then
		URL="https://gitlab.gnome.org/GNOME/glib"
	elif [[ "$1" == "gtk" || "$1" == "gtk3" || "$1" == "gtk4" ]]; then
		URL="https://gitlab.gnome.org/GNOME/gtk"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi

	if [[ "${1}${2}" == "gtk3" || "$1" == "gtk3" ]]; then
		timeout 15 git ls-remote --tags --refs "$URL.git" 2>/dev/null \
		| cut -d '/' -f 3 \
		| grep -viE "alpha|beta|rc|dev|snapshot|init|\.9[0-9]" \
		| grep -E "^3\.[02468]+\.[0-9]+$" | sort -V | tail -n 1
	elif [[ "${1}${2}" == "gtk4" || "$1" == "gtk" || "$1" == "gtk4" ]]; then
		timeout 15 git ls-remote --tags --refs "$URL.git" 2>/dev/null \
		| cut -d '/' -f 3 \
		| grep -viE "alpha|beta|rc|dev|snapshot|init|\.9[0-9]" \
		| grep -E "^${2:-4}\.[02468]+\.[0-9]+$" | sort -V | tail -n 1
	elif [[ "${1}" == "gjs" ]]; then
		timeout 15 git ls-remote --tags --refs "$URL.git" 2>/dev/null \
		| cut -d '/' -f 3 \
		| grep -viE "alpha|beta|rc|dev|snapshot|init|\.9[0-9]" \
		| grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" \
		| grep -vE "[0-9]+\.[0-9]+\.9[0-9]$" | sort -V | tail -n 1
	elif [[ "$1" == "libsoup" ]]; then
		timeout 15 git ls-remote --tags --refs "$URL.git" 2>/dev/null \
		| cut -d '/' -f 3 \
		| grep -viE "alpha|beta|rc|dev|snapshot|init|\.9[0-9]" \
		| grep -E "^[0-9]+\.[02468]+\.[0-9]+$" \
		| grep -vE "[0-9]+\.[0-9]+\.9[0-9]$" | sort -V | tail -n 1
	elif [[ "$1" == "glib2"  || "$1" == "glib-networking" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL.git" 2> /dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| grep -E "^[0-9.]+$" | sort -V | tail -n 1
	else		
    	timeout 5 git ls-remote --tags --refs "$URL.git" 2>/dev/null \
		| cut -d '/' -f 3 \
		| grep -viE "alpha|beta|rc|dev|snapshot|init|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' \
		| tr '_' '.' | grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" \
		| sort -V | tail -n 1
	fi
}

function glgd {
	local URL="https://gitlab.gnome.org/World/gedit/$1.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 \
	| grep -v ".9" | sort -V | tail -n 1
}

function glp_ver {
	local URL="https://gitlab.gnome.org/GNOME/libpeas.git"
	timeout 5 git ls-remote --tags --refs "$URL" | grep "refs/tags/libpeas-1" \
	| cut -d '-' -f 2 | sort -V | tail -n 1
}

function wgn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	elif [[ "$1" == "gedit" ]]; then
		URL="https://gitlab.gnome.org/World/gedit/gedit"
	elif [[ "$1" == "glib2" ]]; then
		URL="https://gitlab.gnome.org/GNOME/glib"
	elif [[ "$1" == "gtk" || "$1" == "gtk3" || "$1" == "gtk4" ]]; then
		URL="https://gitlab.gnome.org/GNOME/gtk"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi
    if [[ "$1" == "gtk3" || "$2" == "3" ]]; then
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^3\.[02468]+" | sort -V \
		| tail -n 1
    elif [[ "$1" == "gtk" || "$1" == "gtk4" || "$2" == "4" ]]; then
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^4\.[02468]+\.[0-9]+$" \
		| sort -V | tail -n 1
	elif [[ "$1" == "gjs" ]]; then
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" \
		| grep -vE "[0-9]+\.[0-9]+\.9[0-9]" | sort -V | tail -n 1
    elif [[ "$1" == "libsoup" ]]; then
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' \
		| grep -E "^[0-9]+\.[02468]+\.[0-9]+$" \
		| grep -vE "[0-9]+\.[0-9]+\.9[0-9]" | sort -V | tail -n 1
    elif [[ "$1" == "glib2" || "$1" == "glib-networking" ]]; then
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" | sort -V \
		| tail -n 1
    else
	    wget -T 10 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" \
		| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
		| sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' \
		| grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" | sort -V \
		| tail -n 1
    fi
}

function wlgd_ver {
    wget -T 5 -t 1 -cqO- https://gitlab.gnome.org/World/gedit/$1/-/tags \
	| grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 \
	| cut -d '/' -f 7 | head -n 1
}

function wlp_ver {
	wget -T 5 -t 1 -cqO- "$1/-/tags" | grep -oE "tags/[^\"]+" \
	| sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" \
	| sed -E 's/libpeas-//g' | grep '^1' | sort -V | tail -n 1
}
