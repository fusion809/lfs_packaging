#!/bin/bash
function aver {
	wget -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$1/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2
}

function github_ver {
	repo="$1"
	exclude="$2"
	prefix="$3"
	if [[ -n "$2" ]] && [[ -n "$3" ]]; then
		wget -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "$2" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed "s/^$prefix//g"
	elif [[ -n "$2" ]]; then
		wget -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "$2" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6
	else
		wget -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6
	fi

}
