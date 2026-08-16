#!/bin/bash
GIT_TERMINAL_PROMPT=0
function aver {
    local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
	wget --timeout=5 -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2
}

function fdt_ver {
    local repo=${1:-$repo}
    wget --timeout=5 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" | grep -oE 'tags/[v0-9.][^"]*' | grep -vE "dev|rc|alpha|beta" | sed 's|tags/||; s/^v//' | sort -V | tail -n 1
}

function gh_com {
    git ls-remote https://github.com/$1.git HEAD | awk '{ print $1 }'
}

function gfl_ver {
    git ls-remote --tags "https://gitlab.freedesktop.org/$1.git" | sed -n 's|.*refs/tags/v\?\([0-9][0-9.]*\)$|\1|p' | grep -vE "dev|rc|alpha|beta" | sort -V | tail -1
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

function gsp_ver {
    git ls-remote --tags --refs https://gitlab.freedesktop.org/$1.git | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed -E 's|[a-z_-]+||g' | sort -V | tail -n 1
}

function gxfd_ver {
    git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$1/$2.git | grep "$2-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1
}

function lfs_ver {
	wget --timeout=5 -cqO- https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html https://www.linuxfromscratch.org/blfs/view/systemd/longindex.html https://www.linuxfromscratch.org/slfs/view/stable/ | grep -iE ">$1-[0-9.]+" | sed -E "s/.*$1-([0-9.]+).*/\1/I" | grep -E "^[0-9.]+$" | sort -V | tail -n 1
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

function wsp_ver {
	local repo_url=$(echo $1 | sed "s|/|%2F|g")
    wget --timeout=5 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/${repo_url}/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | sed -E 's|[a-z_-]+||g' | head -n 1 | cut -d'"' -f4
}

function wxfd_ver {
    wget --timeout=5 -cqO- https://xorg.freedesktop.org/archive/individual/$1/ | grep "$2-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.*$//g' | sort -V | tail -n 1
}
