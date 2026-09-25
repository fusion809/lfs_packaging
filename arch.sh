#!/bin/bash
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