#!/bin/bash
function aver {
	wget --timeout=5 -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$1/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2
}

# Echoes $1 and returns 0 if it looks like a valid version string, otherwise returns 1.
function ver_check {
	if echo "$1" | grep -qE "[0-9.]+"; then
		echo "$1"
		return 0
	fi
	return 1
}

function pkgver {
        find /var/lib/{book,custom}-packages -type f -name "$1" -exec sh -c '
    for file; do
        head -n1 "$file"
    done
' sh {} +
}

function lfs_ver {
	wget --timeout=5 -cqO- https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html | grep -iE "$1-[0-9.]+" | sed "s/.*$1-//I" | sed 's|</a>||g' | grep -E "^[0-9.]+$" | tail -n 1
}

function gfd_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 2 | tr '[:upper:]' '[:lower:]')
	local up_ver=$(wget --timeout=5 -cqO- https://gitlab.freedesktop.org/$repo/-/tags | grep "tags/" | grep -v "dev\|rc" | cut -d '/' -f 6 | sed 's/".*//g' | sort -V | tail -n 1)
	ver_check "$up_ver" && return

	local git_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/$repo.git | sed -n 's|.*refs/tags/\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -1)
	ver_check "$git_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return

	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
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
	ver_check "$up_ver" && return

	local git_ver=$(ghl_ver $1)
	ver_check "$git_ver" && return

	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
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
	ver_check "$up_ver" && return

	local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$type/$name.git | grep "$name-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" && return

	local arch_ver=$(aver "$(echo $name | tr '[:upper:]' '[:lower:]')")
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}

function gn_ver {
	if [[ "$1" == "gtk3" ]]; then
		local up_ver=$(wget --timeout=5 -cqO- https://gitlab.gnome.org/GNOME/gtk/-/tags | grep "tags/" | grep "\-3\." | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g')
		ver_check "$up_ver" && return

		local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/GNOME/gtk.git" | grep "refs/tags/3" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1)
		ver_check "$git_ver" && return
	else
		local up_ver=$(wget -cqO- https://gitlab.gnome.org/GNOME/$1/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g')
		ver_check "$up_ver" && return
		local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/GNOME/$1.git" | grep "refs/tags/v[0-9]" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
		ver_check "$git_ver" && return
	fi
	local arch_ver=$(aver "${2:-$1}")
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}

function lgd_ver {
	local name=$1
	local up_ver=$(wget --timeout=5 -cqO- https://gitlab.gnome.org/World/gedit/$name/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 7 | head -n 1)
	ver_check "$up_ver" && return

	local git_ver=$(git ls-remote --tags --refs "https://gitlab.gnome.org/World/gedit/$name.git" | grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1)
	ver_check "$git_ver" && return
	local arch_ver=$(aver "$name")
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}

function spice_ver {
	local name=$1
	local up_ver=$(wget --timeout=5 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/spice%2F$name/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | head -n 1 | cut -d'"' -f4 | sed 's/^v//')
	ver_check "$up_ver" && return

	local git_ver=$(GIT_TERMINAL_PROMPT=0 git ls-remote --tags --refs https://gitlab.com/spice/$name.git | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed 's/v//g' | sort -V | tail -n 1)
	ver_check "$git_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}

function sf_ver {
    local up_ver=$(wget --timeout=5 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep "/tree" | grep -v "alpha\|beta\|rc" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6)
	ver_check "$up_ver" && return
    local git_ver=$(git ls-remote --tags --refs https://git.code.sf.net/p/$1.git | grep "tags/[v0-9.]+" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" && return
	local name=$(echo $1 | cut -d '/' -f 1)
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}

function gnu_ver {
	local name=$1
	local up_ver=$(wget  --timeout=5 -cqO- https://ftp.gnu.org/gnu/$name/ | grep -E "$name-[0-9.]+.tar.[a-z]*\"" | sed "s/.*$name-//g" | sed 's/.tar.*//g' | cut -d '"' -f 1 | uniq | sort -V | tail -n 1)
	ver_check "$up_ver" && return
	if [[ "$name" == "octave" ]]; then
		local git_ver=$(git ls-remote --tags --refs https://github.com/gnu-octave/octave.git | grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' | sed 's/-/./g' | sort -V | tail -n1)
	elif [[ "$name" == "glpk" ]]; then
		local git_ver=$(git ls-remote --tags --refs https://salsa.debian.org/science-team/glpk.git | grep "upstream" | cut -d '/' -f 4 | sort -V | tail -n 1)
	elif [[ "$name" == "libtool" ]]; then
		local git_ver=$(git ls-remote --tags --refs git://git.savannah.gnu.org/libtool.git | cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1)
	fi
	ver_check "$git_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}

function way_ver {
    local name=$1
    local up_ver=$(wget -T 5 -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
    ver_check "$up_ver" && return

    local git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/wayland/$name.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
    ver_check "$git_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" && return
}