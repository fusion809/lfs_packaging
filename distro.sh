#!/bin/bash
function artver {
	local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
	local ver=$(wget -T 5 -t 1 -cqO- https://packages.artixlinux.org/packages/{world,system,galaxy}/{x86_64,any}/$name/ | grep "$name [0-9.]+[a-z0-9]*" -oE | head -n 1 | cut -d ' ' -f 2)
	if [[ "$name" == "gcc" ]]; then
		echo $ver | sed -E 's/\.1$/\.0/g'
	else
		echo $ver
	fi
}

function aurver {
	local name="$1"
	if [[ -n $2 ]]; then
		local var="$2"
	else
		local var="pkgver"
	fi
	local URL="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$name"
	wget -T 5 -t 1 -cqO- "$URL" | grep "^$var=" | sed "s/^$var=//g"
}

function check_arch {
	wget -T 5 -t 1 -cqO- "https://archlinux.org/packages/search/json/?name=$1" | grep "\"pkgname\": \"$1\""
}

function check_aur {
	wget -T 5 -t 1 -cqO- "https://aur.archlinux.org/rpc/v5/info?arg%5B%5D=$1" | grep "\"Name\":\"$1\""
}

function aver {
	local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
    	if echo $(check_arch $name) &> /dev/null; then
		local URL="https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/raw/main/PKGBUILD"
		local pkgver=$(wget -cqO- "$URL" | grep -E "^pkgver=[0-9.a-z]+$" | sed 's/^pkgver=//g')
	elif echo $(check_aur $name) &> /dev/null; then
		local pkgver=$(aurver "$name")
	else
		echo "$(date +"%r %d/%m/%Y"), $name" > ~/logs/failed_arch_versioning.log
	fi

	if [[ "$name" == "gcc" ]]; then
		echo "$pkgver" | sed 's/\.1+r.*/\.0/g'
	else
		echo "$pkgver"
	fi
}

function gent_ver {
	local pkg="$1"
	local name=$(echo $pkg | cut -d '/' -f 2)
	wget -T 5 -t 1 -cqO- https://packages.gentoo.org/packages/$pkg \
	| grep -oE "$name-[0-9.]+ebuild" | sed 's/\.ebuild//g' | sed "s/$name-//g" \
	| sort -V | tail -n 1
}

function gver {
	local repo=$1
	local URL="https://gitweb.gentoo.org/repo/gentoo.git/tree/$repo"
	wget -T 5 -t 1 -cqO- "$URL" | grep "\-[0-9]+\.[0-9.]+[_p0-9]*" -oE \
	| grep -v "9999" | grep -vE "[prc][0-9]+" | sed 's/^-//g' \
	| sed 's/\.$//g' | sort -V | tail -n 1
}

function lfs_ver {
	# Some local package names differ from LFS/BLFS tarball names — map them here.
	# fallback_page: relative path to the individual BLFS page for packages whose
	# version doesn't appear in the index pages (e.g. listed by display name, not tarball).
	local search_name fallback_page
	case "$1" in
		mitkrb) search_name="krb5"; fallback_page="blfs-mitkrb.html" ;;
		vte) search_name="vte" ; fallback_page="blfs-vte.html";;
		*)       search_name="$1";  fallback_page="" ;;
	esac

	# Try the index pages first.
	local ver
	ver=$(cat $HOME/.cache/*lfs*index.html \
		| grep -iE ">$search_name-[0-9.]+" \
		| grep -v "docbook5.html" \
		| grep -vE "vte-2\.[0-9]+" \
		| grep -v "\.so" \
		| grep -v "emu/dolphin" \
		| sed -E "s/.*$search_name-([0-9.]+[-rc0-9]*).*/\1/I" \
		| grep -E "^[0-9.]+[-rc0-9]*$" | sed 's|-$||g' | sort -V | tail -n 1)

	# If not found and a fallback page is defined, scrape the individual BLFS page.
	if [[ -z "$ver" && -n "$fallback_page" ]]; then
		ver=$(cat $HOME/.cache/$fallback_page \
			| grep -iE "$search_name-[0-9]+\.[0-9]" \
			| sed -E "s/.*$search_name-([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/I" \
			| grep -E "^[0-9.]+[-rc0-9]*$" | sort -V | tail -n 1)
	fi
	echo "$ver"
}

function nixver {
    if [[ -z "$1" ]]; then
        echo "Usage: nixver PACKAGE" >&2
        return 1
    fi

    local pkg="$1"
    local index
    local response

    index=$(
        wget -qO- \
            --user='aWVSALXpZv' \
            --password='X8gPHnzL52wFEekuxsfQ9cSh' \
            'https://search.nixos.org/backend/_aliases' |
        grep -oE 'latest-[0-9]+-nixos-unstable' |
        sed 's/^latest-\([0-9][0-9]*\)-nixos-unstable$/\1/' |
        sort -n |
        tail -n1
    )

    if [[ -z "$index" ]]; then
        echo "Could not determine current NixOS Search index" >&2
        return 1
    fi

    response=$(
        wget -qO- \
            --user='aWVSALXpZv' \
            --password='X8gPHnzL52wFEekuxsfQ9cSh' \
            --header='Content-Type: application/json' \
            --post-data="{\"query\":{\"bool\":{\"filter\":[{\"term\":{\"type\":\"package\"}}],\"must\":[{\"term\":{\"package_attr_name\":\"$pkg\"}}]}}}" \
            "https://search.nixos.org/backend/latest-${index}-nixos-unstable/_search"
    ) || return 1

    printf '%s\n' "$response" |
        sed -n 's/.*"package_pversion":"\([^"]*\)".*/\1/p' |
        head -n1
}

function vatver {
	export VAT_URL="https://raw.githubusercontent.com/tox-wtf/vat/refs/heads/master/p/"
	wget -cqO- -T 5 -t 1 "$VAT_URL/$1/v.tsv" | grep -F release | cut -f3
}
