#!/bin/bash
GIT_TERMINAL_PROMPT=0
function aver {
	local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
	local URL="https://gitlab.archlinux.org/archlinux/packaging/packages/$name/-/raw/main/PKGBUILD"
	if [[ -n $2 ]]; then
		local no="$2"
	else
		local no=1
	fi
    wget -T 5 -t 1 -cqO- "$URL" | grep -E "^[_]*pkgver=" | cut -d '=' -f 2 | head -n "$no" | tail -n 1
}

function fdt_ver {
    local repo=$1
    wget --timeout=5 -t 1 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" | grep -oE 'tags/[v0-9.][^"]*' | grep -vE "dev|rc|alpha|beta" | sed 's|tags/||; s/^v//' | sort -V | tail -n 1
}

function fver {
	echo "$(date +"%r %d/%m/%Y"), $1\n" >> ~/logs/failed_versioning.log
	echo "$2"
}

function gh_com {
    timeout 5 git ls-remote https://github.com/$1.git HEAD 2>/dev/null | awk '{ print $1 }'
}

function gfl_ver {
    timeout 5 git ls-remote --tags "https://gitlab.freedesktop.org/$1.git" 2>/dev/null | sed -n 's|.*refs/tags/v\?\([0-9][0-9.]*\)$|\1|p' | grep -vE "dev|rc|alpha|beta" | sort -V | tail -1
}

function gglpk_ver {
    timeout 5 git ls-remote --tags --refs https://salsa.debian.org/science-team/glpk.git 2>/dev/null | grep "upstream" | cut -d '/' -f 4 | sort -V | tail -n 1
}

function ggn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi

    timeout 5 git ls-remote --tags --refs "$URL.git" 2>/dev/null | grep "refs/tags/$2" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sed 's/^v//g'| sort -V | tail -n 1
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
    timeout 5 git ls-remote --tags --refs https://github.com/$1.git 2>/dev/null | cut -d '/' -f 3 | sed 's/^[a-zA-Z0-9-]*-//g' | sed 's/^v//g' | grep -E "^[0-9.]+$" | sort -V | tail -n 1
}

function ght_ver {
	local latest_url=$(curl --max-time 5 --connect-timeout 5 -Ls -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest")
	local latest_tag=$(echo "$latest_url" | grep -oP '/tag/\K.*')
	if [[ -n "$latest_tag" ]]; then
		echo "$latest_tag" | sed -nE "s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([.-][0-9]+)*).*/\1/p" | head -n 1
		return 0
	fi
	wget --timeout=5 -t 1 -cqO- "https://github.com/$1/tags.atom" | grep -v "alpha\|beta\|rc" | grep '<title>' | sed -nE "/<title>Tags from /d; s/.*<title>//; s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([.-][0-9]+)*).*/\1/p" | sort -V | tail -n 1
}

function glgd {
    timeout 5 git ls-remote --tags --refs "https://gitlab.gnome.org/World/gedit/$1.git" 2>/dev/null | grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1
}

function glib_ver {
    timeout 5 git ls-remote --tags --refs git://git.savannah.gnu.org/libtool.git 2>/dev/null | cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1
}

function goct_ver {
    timeout 5 git ls-remote --tags --refs https://github.com/gnu-octave/octave.git 2>/dev/null | grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' | sed 's/-/./g' | sort -V | tail -n1
}

function gsf_ver {
    timeout 5 git ls-remote --tags --refs https://git.code.sf.net/p/$1.git 2>/dev/null | grep "tags/[v0-9.]+" | cut -d '/' -f 3 | sort -V | tail -n 1
}

function gsp_ver {
    timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/$1.git 2>/dev/null | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed -E 's|[a-z_-]+||g' | sort -V | tail -n 1
}

function gxfd_ver {
    timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$1/$2.git 2>/dev/null | grep "$2-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1
}

function lfs_ver {
	wget --timeout=5 -t 1 -cqO- https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html https://www.linuxfromscratch.org/blfs/view/systemd/longindex.html https://www.linuxfromscratch.org/slfs/view/stable/ | grep -iE ">$1-[0-9.]+" | sed -E "s/.*$1-([0-9.]+).*/\1/I" | grep -E "^[0-9.]+$" | sort -V | tail -n 1
}

function wgn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi
    wget --timeout=5 -t 1 -cqO- $URL/-/tags | grep "tags/$2" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | sort -V | tail -n 1 | sed 's/^v//g'
}

function wgnu_ver {
    wget --timeout=5 -t 1 -cqO- https://ftp.gnu.org/gnu/$1/ | grep -E "$1-[0-9.]+.tar.[a-z]*\"" | sed "s/.*$1-//g" | sed 's/.tar.*//g' | cut -d '"' -f 1 | uniq | sort -V | tail -n 1
}

function wlgd_ver {
    wget --timeout=5 -t 1 -cqO- https://gitlab.gnome.org/World/gedit/$1/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 7 | head -n 1
}

function wsf_ver {
    wget --timeout=5 -t 1 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep "/tree" | grep -v "alpha\|beta\|rc" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6
}

function wsp_ver {
	local repo_url=$(echo $1 | sed "s|/|%2F|g")
    wget --timeout=5 -t 1 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/${repo_url}/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | sed -E 's|[a-z_-]+||g' | head -n 1 | cut -d'"' -f4
}

function wxfd_ver {
    wget --timeout=5 -t 1 -cqO- https://xorg.freedesktop.org/archive/individual/$1/ | grep "$2-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.*$//g' | sort -V | tail -n 1
}
