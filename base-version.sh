#!/bin/bash
GIT_TERMINAL_PROMPT=0
function aver {
    local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
	wget --timeout=5 -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2
}

function fdt_ver {
    wget --timeout=5 -cqO- https://gitlab.freedesktop.org/$repo/-/tags | grep "tags/" | grep -v "dev\|rc" | cut -d '/' -f 6 | sed 's/".*//g' | sort -V | tail -n 1
}

function gh_com {
    git ls-remote https://github.com/$repo.git HEAD
}

function gfl_ver {
    git ls-remote --tags "https://gitlab.freedesktop.org/$1.git" | sed -n 's|.*refs/tags/\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -1
}

function gglpk_ver {
    git ls-remote --tags --refs https://salsa.debian.org/science-team/glpk.git | grep "upstream" | cut -d '/' -f 4 | sort -V | tail -n 1
}

function ggn_ver {
    git ls-remote --tags --refs "https://gitlab.gnome.org/GNOME/$1.git" | grep "refs/tags/$2" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sed 's/^v//g'| sort -V | tail -n 1
}

function ggnu_ver {
    local name=$1
    if [[ "$name" == "octave" ]]; then
		echo $(goct_ver)
        return 0;
	elif [[ "$name" == "glpk" ]]; then
	    echo $(gglpk_ver)
        return 0;
	elif [[ "$name" == "libtool" ]]; then
	    echo $(glib_ver)
        return 0;
	fi
}

function ghl_ver {
    git ls-remote --tags --refs https://github.com/$1 | cut -d '/' -f 3 | sed 's/v//g' | tail -n 1
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

function glgd {
    git ls-remote --tags --refs "https://gitlab.gnome.org/World/gedit/$1.git" | grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1
}

function glib_ver {
    git ls-remote --tags --refs git://git.savannah.gnu.org/libtool.git | cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1
}

function goct_ver {
    git ls-remote --tags --refs https://github.com/gnu-octave/octave.git | grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' | sed 's/-/./g' | sort -V | tail -n1
}

function gsf_ver {
    git ls-remote --tags --refs https://git.code.sf.net/p/$1.git | grep "tags/[v0-9.]+" | cut -d '/' -f 3 | sort -V | tail -n 1
}

function gxfd_ver {
    git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$1/$2.git | grep "$2-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1
}

function lfs_ver {
	wget --timeout=5 -cqO- https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html https://www.linuxfromscratch.org/slfs/view/stable/ | grep -iE ">$1-[0-9.]+" | sed "s/.*$1-//I" | sed 's|</a>||g' | grep -E "^[0-9.]+$" | tail -n 1
}

function wgn_ver {
    wget --timeout=5 -cqO- https://gitlab.gnome.org/GNOME/$1/-/tags | grep "tags/$2" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g'
}

function wgnu_ver {
    wget  --timeout=5 -cqO- https://ftp.gnu.org/gnu/$1/ | grep -E "$1-[0-9.]+.tar.[a-z]*\"" | sed "s/.*$1-//g" | sed 's/.tar.*//g' | cut -d '"' -f 1 | uniq | sort -V | tail -n 1
}

function wlgd_ver {
    wget --timeout=5 -cqO- https://gitlab.gnome.org/World/gedit/$1/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 7 | head -n 1
}

function wsf_ver {
    wget --timeout=5 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep "/tree" | grep -v "alpha\|beta\|rc" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6
}

function wxfd_ver {
    wget --timeout=5 -cqO- https://xorg.freedesktop.org/archive/individual/$1/ | grep "$2-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.*$//g' | sort -V | tail -n 1
}
