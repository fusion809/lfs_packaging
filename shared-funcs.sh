#!/bin/bash
function aver {
	wget --timeout=5 -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$1/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2
}

function github_ver {
	repo="$1"
	exclude="$2"
	prefix="$3"
	if [[ -n "$2" ]] && [[ -n "$3" ]]; then
		wget --timeout=5 -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "$2" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed "s/^$prefix//g"
	elif [[ -n "$2" ]]; then
		wget --timeout=5 -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "$2" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6
	else
		wget --timeout=5 -cqO- https://github.com/"$repo"/releases | grep "/tag/" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6
	fi
}

function ght_ver {
	local latest_url=$(curl -Ls -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest")
	local latest_tag=$(echo "$latest_url" | grep -oP '/tag/\K.*')
	if [[ -n "$latest_tag" ]]; then
		echo "$latest_tag" | sed -nE "s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([.-][0-9]+)*).*/\1/p"
		return 0
	fi
	wget --timeout=5 -cqO- "https://github.com/$1/tags.atom" | grep -v "alpha\|beta\|rc" | grep '<title>' | sed -nE "/<title>Tags from /d; s/.*<title>//; s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([.-][0-9]+)*).*/\1/p" | sort -V | tail -n 1
}
function ghl_ver {
    git ls-remote --tags --refs https://github.com/$1 | cut -d '/' -f 3 | sed 's/v//g' | tail -n 1
}

function gh_ver {
	local up_ver=$(ght_ver $1)
	if echo "$up_ver" | grep -qP "[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(ghl_ver $1)
	if echo "$git_ver" | grep -qP "[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -qP "[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}
function xfd_ver() {
	name="$1"
	if echo $name | grep "lib" &> /dev/null || [[ "$name" == "xtrans" ]]; then
		type="lib"
	elif echo $name | grep "xf86" &> /dev/null; then
		type="driver"
	else
		type="app"
	fi
	local up_ver=$(wget --timeout=5 -cqO- https://xorg.freedesktop.org/archive/individual/$type/ | grep "$name-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.*$//g' | sort -V | tail -n 1)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$type/$name.git | grep "$name-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	local arch_ver=$(aver "$(echo $name | tr '[:upper:]' '[:lower:]')")
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

function gn_ver {
	if [[ "$1" == "gtk3" ]]; then
		local up_ver=$(wget --timeout=5 -cqO- https://gitlab.gnome.org/GNOME/gtk/-/tags | grep "tags/" | grep "\-3\." | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g')
		if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
			echo "$up_ver"
			return 0
		fi

		local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/GNOME/gtk.git" | grep "refs/tags/3" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1)
		if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
			echo "$git_ver"
			return 0
		fi
	else
		local up_ver=$(wget -cqO- https://gitlab.gnome.org/GNOME/$1/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g')
		if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
			echo "$up_ver"
			return 0
		fi
		local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/GNOME/$1.git" | grep "refs/tags/v[0-9]" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
		if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
			echo "$git_ver"
			return 0
		fi
	fi
	local arch_ver=$(aver "${2:-$1}")
	if echo "$arch_ver" | grep -qP "[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

function lgd_ver {
	local name=$1
	local up_ver=$(wget --timeout=5 -cqO- https://gitlab.gnome.org/World/gedit/$name/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 7 | head -n 1)
	
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/World/gedit/$name.git" | grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi
	local arch_ver=$(aver "$name")
	if echo "$arch_ver" | grep -qP "[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

function spice_ver {
	local name=$1
	local up_ver=$(wget --timeout=5 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/spice%2F$name/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | head -n 1 | cut -d'"' -f4 | sed 's/^v//')
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi
	local git_ver=$(git ls-remote --tags --refs https://gitlab.com/spice/$name.git | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed 's/v//g' | sort -V | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]" &> /dev/null && ! ( [[ $name == "spice-protocol" ]] && [[ $git_ver == "0.14.4" ]] ) && ! ( [[$name == "spice" ]] && [[ $git_ver == "0.15.0" ]] ); then
		echo "$git_ver"
		return 0
	fi
	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

function sf_ver {
    local up_ver=$(wget --timeout=5 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep "/tree" | grep -v "alpha\|beta\|rc" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6)
    if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi
    local git_ver=$(git ls-remote --tags --refs https://git.code.sf.net/p/$1.git | grep "tags/[v0-9.]+" | cut -d '/' -f 3 | sort -V | tail -n 1)
    if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi
	local name=$(echo $1 | cut -d '/' -f 1)
    local arch_ver=$(aver $name)
    if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

function gnu_ver {
	local name=$1
	local up_ver=$(wget  --timeout=5 -cqO- https://ftp.gnu.org/gnu/$name/ | grep -E "$name-[0-9.]+.tar.[a-z]*\"" | sed "s/.*$name-//g" | sed 's/.tar.*//g' | cut -d '"' -f 1 | uniq | sort -V | tail -n 1)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi
	if [[ "$name" == "octave" ]]; then
		local git_ver=$(git ls-remote --tags --refs https://github.com/gnu-octave/octave.git | grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' | sed 's/-/./g' | sort -V | tail -n1)
	elif [[ "$name" == "glpk" ]]; then
		local git_ver=$(git ls-remote --tags --refs https://salsa.debian.org/science-team/glpk.git | grep "upstream" | cut -d '/' -f 4 | sort -V | tail -n 1)
	elif [[ "$name" == "libtool" ]]; then
		local git_ver=$(git ls-remote --tags --refs git://git.savannah.gnu.org/libtool.git | cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1)
	fi
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi
	local arch_ver=$(aver $name)
    	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}
