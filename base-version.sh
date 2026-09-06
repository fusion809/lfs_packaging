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
    if [[ $repo != "gstreamer/gstreamer" ]]; then
    	wget --timeout=5 -t 1 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" | grep -oE 'tags/[v0-9.][^"]*' | grep -vE "dev|rc|alpha|beta" | sed 's|tags/||; s/^v//' | sort -V | tail -n 1
    else
    	wget --timeout=5 -t 1 -cqO- "https://gitlab.freedesktop.org/$repo/-/tags" | grep -oE 'tags/[v0-9.][^"]*' | grep -vE "dev|rc|alpha|beta" | sed 's|tags/||; s/^v//' | grep -oE "[0-9]+\.[0-9]*[02468]\.[0-9]+" | sort -V | tail -n 1
    fi
}

function fver {
	# Only log as a failure when inst_ver is also unknown.
	# If inst_ver is set, upstream sources are temporarily unreachable/stale —
	# return the installed version silently rather than spamming the log.
	if [[ -z "$2" ]]; then
		echo "$(date +"%r %d/%m/%Y"), $1" >> ~/logs/failed_versioning.log
	fi
	echo "$2"
}

function gent_ver {
	local pkg="$1"
	local name=$(echo $pkg | cut -d '/' -f 2)
	wget -T 5 -t 1 -cqO- https://packages.gentoo.org/packages/$pkg | grep -oE "$name-[0-9.]+ebuild" | sed 's/\.ebuild//g' | sed "s/$name-//g" | sort -V | tail -n 1
}

function gh_com {
    timeout 5 git ls-remote https://github.com/$1.git HEAD 2>/dev/null | awk '{ print $1 }'
}

function gfl_ver {
    if [[ "$1" != "gstreamer/gstreamer" ]]; then
	    timeout 5 git ls-remote --tags "https://gitlab.freedesktop.org/$1.git" 2>/dev/null | sed -n 's|.*refs/tags/v\?\([0-9][0-9.]*\)$|\1|p' | grep -vE "dev|rc|alpha|beta" | sort -V | tail -1
    else
	    timeout 5 git ls-remote --tags "https://gitlab.freedesktop.org/$1.git" 2>/dev/null | sed -n 's|.*refs/tags/v\?\([0-9][0-9.]*\)$|\1|p' | grep -vE "dev|rc|alpha|beta" | grep -oE "[0-9]+\.[0-9]*[02468]\.[0-9]+" | sort -V | tail -1
    fi

}

function gglpk_ver {
    timeout 5 git ls-remote --tags --refs https://salsa.debian.org/science-team/glpk.git 2>/dev/null | grep "upstream" | cut -d '/' -f 4 | sort -V | tail -n 1
}

function ggn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	elif [[ "$1" == "gedit" ]]; then
		URL="https://gitlab.gnome.org/World/gedit/gedit"
	elif [[ "$1" == "glib2" ]]; then
		URL="https://gitlab.gnome.org/GNOME/glib"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi

	if [[ "${1}${2}" == "gtk3" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL.git" 2>/dev/null | cut -d '/' -f 3 | grep -E "^3\.[02468]+\.[0-9]+$" | sort -V | tail -n 1
	elif [[ "$1" == "gtk" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL.git" 2>/dev/null | cut -d '/' -f 3 | grep -E "^[0-9]\.[02468]+\.[0-9]+$" | sort -V | tail -n 1
	else		
    	timeout 5 git ls-remote --tags --refs "$URL.git" 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|\.9[0-9]" | sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' | grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" | sort -V | tail -n 1
	fi
}

function ggcc_ver {
    timeout 5 git ls-remote --tags --refs https://gitlab.com/gnutools/gcc.git 2>/dev/null | grep -oE "releases/gcc-[0-9]+\.[0-9]+\.[0-9]+" | sed "s|releases/gcc-||" | sort -V | tail -n 1
}

function ggrub_ver {
	timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/gnu-grub/grub.git | grep -E "grub-[0-9]+\.[0-9]+$" | cut -d '-' -f 2 | sort -V | tail -n 1
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
	    timeout 5 git ls-remote --tags --refs https://https.git.savannah.gnu.org/git/libunistring.git | grep "refs/tags/v[0-9.]+" -oE | sed 's/.*v//g' | sort -V | tail -n 1
	    return 0;
    elif [[ "$name" == "nettle" ]]; then
	    timeout 5 git ls-remote --tags --refs https://git.lysator.liu.se/nettle/nettle.git | grep "refs/tags/nettle_[0-9.]+_release" -oE | cut -d '_' -f 2 | sort -V | tail -n 1
	    return 0;
    else
        timeout 5 git ls-remote --tags --refs "https://https.git.savannah.gnu.org/git/$name.git" 2>/dev/null | cut -d '/' -f 3 | sed -E "s/^(${name}|release)[-_]//; s/^[vVrR]//" | grep -viE "alpha|beta|rc|dev|snapshot" | grep -E '^[0-9]+(\.[0-9]+)+$' | sort -V | tail -n 1
        return 0;
	fi
}

function ghl_ver {
	if [[ "$1" == "openpmix/prrte" ]]; then
		timeout 5 git ls-remote --tags --refs https://github.com/$1.git 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot" | sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' | grep -E "^[0-9]+(\.[0-9]+)+$" | grep "^3" | sort -V | tail -n 1
	elif [[ "$1" == "GNOME/librsvg" ]]; then
		timeout 5 git ls-remote --tags --refs https://github.com/$1.git 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot" | sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' | grep -E "^[0-9]+(\.[0-9]+)+$" | grep -oE "[0-9]+.[0-9]+.[0-8][0-9]*" | sort -V | tail -n 1
	elif [[ "$1" == "KhronosGroup/Vulkan-Loader" ]] || [[ "$1" == "KhronosGroup/Vulkan-Headers" ]]; then
            timeout 5 git ls-remote --tags --refs https://github.com/$1.git 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot" | sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' | grep -E "^[0-9]+(\.[0-9]+)+$" | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
	else
		timeout 5 git ls-remote --tags --refs https://github.com/$1.git 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot" | sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' | grep -E "^[0-9]+(\.[0-9]+)+$" | tr '-' '.' | sort -V | tail -n 1
	fi
}

#function ght_ver {
#	local latest_url=$(curl --max-time 10 --connect-timeout 3 -Ls -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest")
#	local latest_tag=$(echo "$latest_url" | grep -oP '/tag/\K.*')
#	if [[ -n "$latest_tag" ]]; then
#		echo "$latest_tag" | sed -nE "s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([._-][0-9]+)*).*/\1/p" | tr '_' '.' | head -n 1
#		return 0
#	fi
#	if [[ "$1" == "webmproject/libvpx" ]]; then
#		wget -T 5 -t 1 -cqO- https://github.com/webmproject/libvpx/tags.atom | grep "link.*v[0-9.]+" -oE | sed 's/.*v//g' | head -n 1
#	else
#		wget --timeout=5 -t 1 -cqO- "https://github.com/$1/tags.atom" | grep -v "alpha\|beta\|rc" | grep '<title>' | sed -nE "/<title>Tags from /d; s/.*<title>//; s/^${1#*/}[[:space:]_-]*//i; s/^[^0-9]*([0-9]+([._-][0-9]+)*).*/\1/p" | tr '_' '.' | sort -V | tail -n 1
#	fi
#}
function ght_ver {
    local repo="$1"
    local latest_url
    local latest_tag
    local version

    latest_url=$(curl --max-time 10 --connect-timeout 3 -Ls \
        -o /dev/null -w '%{url_effective}' \
        "https://github.com/$repo/releases/latest")

    latest_tag=$(grep -oP '/tag/\K.*' <<< "$latest_url")

    # Only use the GitHub "latest release" result if its tag is stable.
    if [[ -n "$latest_tag" ]] && [[ $repo != "GNOME/librsvg" ]] &&
	    [[ $repo != "KhronosGroup/Vulkan-Loader" ]] &&
            [[ $repo != "KhronosGroup/Vulkan-Headers" ]] &&
	! grep -qiE '(alpha|beta|rc|pre|preview|dev|snapshot)' <<< "$latest_tag"; then

        version=$(sed -nE \
            "s/^${repo#*/}[[:space:]_-]*//i;
             s/^[^0-9]*([0-9]+([._-][0-9]+)*).*/\1/p" \
            <<< "$latest_tag" |
            tr '_' '.' | tr '-' '.' |
            head -n 1)

        if [[ -n "$version" ]]; then
            echo "$version"
            return 0
        fi
    fi

    # Special handling for libvpx.
    if [[ "$repo" == "webmproject/libvpx" ]]; then
        wget -T 5 -t 1 -cqO- \
            https://github.com/webmproject/libvpx/tags.atom |
            grep -oE 'link.*v[0-9.]+' |
            sed 's/.*v//' |
            head -n 1
        return
    elif [[ "$repo" == "GNOME/librsvg" ]]; then
	wget -T 5 -t 1 -cqO- \
            https://github.com/$repo/tags.atom | grep -v "beta" |
            grep -oE "[0-9]+\.[0-9]+\.[0-8]" | sort -V | tail -n 1
	return
    elif [[ "$repo" == "KhronosGroup/Vulkan-Loader" ]] || [[ "$repo" == "KhronosGroup/Vulkan-Headers" ]]; then
	wget -T 5 -t 1 -cqO- \
            https://github.com/$repo/tags.atom | grep -v "beta" |
            grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
	return
    fi

    # Fall back to finding the highest stable tag.
    wget --timeout=5 -t 1 -cqO- \
        "https://github.com/$repo/tags.atom" |
        grep '<title>' |
        grep -vE '<title>Tags from |(alpha|beta|rc|pre|preview|dev|snapshot)' |
        sed -nE \
            "s/.*<title>//;
             s/^${repo#*/}[[:space:]_-]*//i;
             s/^[^0-9]*([0-9]+([._-][0-9]+)*).*/\1/p" |
        tr '_' '.' | tr '-' '.' |
        sort -V |
        tail -n 1
}

function glgd {
    timeout 5 git ls-remote --tags --refs "https://gitlab.gnome.org/World/gedit/$1.git" 2>/dev/null | grep "refs/tags/" | grep -v "alpha\|beta\|rc" | cut -d '/' -f 3 | grep -v ".9" | sort -V | tail -n 1
}

function glib_ver {
    timeout 5 git ls-remote --tags --refs git://git.savannah.gnu.org/libtool.git 2>/dev/null | cut -d '/' -f 3 | sed 's/v//g' | grep -v "[a-z]" | sort -V | tail -n 1
}

function gglib2_ver {
	timeout 5 git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/glib.git 2>/dev/null | cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|\.9[0-9]" | grep -E '^[0-9]+(\.[0-9]+)+$' | sort -V | tail -n 1
}

function gkap_ver {
	timeout 5 git ls-remote --tags --refs https://github.com/KDE/$1.git | grep -oE "[0-9]+\.[02468]+\.[0-9]+" | sort -V | tail -n 1
}

function gll_ver {
	timeout 5 git ls-remote --tags --refs https://gitlab.com/$1.git 2> /dev/null | cut -d '/' -f 3 | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -viE "alpha|beta|rc|dev|snapshot" | sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -E "^[0-9]+(\.[0-9]+)+$" | sort -V | tail -n 1
}

function glp_ver {
	timeout 5 git ls-remote --tags --refs https://gitlab.gnome.org/GNOME/libpeas.git | grep "refs/tags/libpeas-1" | cut -d '-' -f 2 | sort -V | tail -n 1
}

function glt_ver {
	local encoded=$(echo "$1" | sed "s|/|%2F|g")
	local api_ver=$(curl -s --connect-timeout 3 --max-time 5 "https://gitlab.com/api/v4/projects/${encoded}/repository/tags?per_page=1" 2>/dev/null | grep -oP '"name":"\K[^"]+' | sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | head -n 1)
	if [[ -n "$api_ver" ]]; then
		echo "$api_ver"
		return 0
	fi
	wget -T 5 -t 1 -cqO- https://gitlab.com/$1/-/tags | grep -E "[v]*[0-9]+\.[0-9]+" | grep "^<a href=" | cut -d '"' -f 2 | cut -d '/' -f 6 | grep -E "^[v]*[0-9.]+$" | sed 's/^v//g' | sort -V | tail -n 1	
}

function gngnu_ver {
	if [[ "$1" == "libpipeline" ]]; then
		URL="https://gitlab.com/libpipeline/libpipeline.git"
	else
		URL="https://https.git.savannah.nongnu.org/git/$1.git"
	fi
	timeout 5 git ls-remote --tags --refs $URL 2>/dev/null | cut -d '/' -f 3 | sed -E 's/^[vVrR]//' | grep -viE "alpha|beta|rc|dev|snapshot" | grep -E '^[0-9]+(\.[0-9]+)+$' | sort -V | tail -n 1
}
function goct_ver {
    timeout 5 git ls-remote --tags --refs https://github.com/gnu-octave/octave.git 2>/dev/null | grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' | sed 's/-/./g' | sort -V | tail -n1
}

function gsf_ver {
	if [[ "$1" == "e2fsprogs/e2fsprogs" ]]; then
		URL="https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git"
	else
		URL="https://git.code.sf.net/p/$1.git"
	fi
    timeout 5 git ls-remote --tags --refs $URL 2>/dev/null | grep -E "tags/[v0-9.]+" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1
}

function gsp_ver {
    timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/$1.git 2>/dev/null | cut -d '/' -f 3 | grep "[0-9]" | grep -v "server\|common\|client" | sed -E 's|[a-z_-]+||g' | sort -V | tail -n 1
}

function gxfd_ver {
    timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/$1/$2.git 2>/dev/null | grep "$2-" -i | cut -d '/' -f 3 | cut -d '-' -f 2 | tr '_' '.' | sort -V | tail -n 1
}

function lfs_ver {
	# Some local package names differ from LFS/BLFS tarball names — map them here.
	# fallback_page: relative path to the individual BLFS page for packages whose
	# version doesn't appear in the index pages (e.g. listed by display name, not tarball).
	local search_name fallback_page
	case "$1" in
		mitkrb) search_name="krb5"; fallback_page="postlfs/mitkrb.html" ;;
		*)       search_name="$1";  fallback_page="" ;;
	esac

	# Try the index pages first.
	local ver
	ver=$(wget --timeout=5 -t 1 -cqO- \
		https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html \
		https://www.linuxfromscratch.org/blfs/view/systemd/longindex.html \
		https://www.linuxfromscratch.org/slfs/view/stable/ \
		| grep -iE ">$search_name-[0-9.]+" \
		| sed -E "s/.*$search_name-([0-9.]+).*/\1/I" \
		| grep -E "^[0-9.]+$" | sort -V | tail -n 1)

	# If not found and a fallback page is defined, scrape the individual BLFS page.
	if [[ -z "$ver" && -n "$fallback_page" ]]; then
		ver=$(wget --timeout=5 -t 1 -cqO- \
			"https://www.linuxfromscratch.org/blfs/view/systemd/$fallback_page" \
			| grep -iE "$search_name-[0-9]+\.[0-9]" \
			| sed -E "s/.*$search_name-([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/I" \
			| grep -E "^[0-9.]+$" | sort -V | tail -n 1)
	fi
	echo "$ver"
}

function wgn_ver {
	if [[ "$1" == "polkit-gnome" ]]; then
		URL="https://gitlab.gnome.org/Archive/policykit-gnome"
	elif [[ "$1" == "gedit" ]]; then
		URL="https://gitlab.gnome.org/World/gedit/gedit"
	elif [[ "$1" == "glib2" ]]; then
		URL="https://gitlab.gnome.org/GNOME/glib"
	else
		URL="https://gitlab.gnome.org/GNOME/$1"
	fi
    if [[ "$1" != "gtk" ]]; then
	    wget --timeout=5 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" | sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" | sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' | grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" | sort -V | tail -n 1
    else
	    wget --timeout=5 -t 1 -cqO- "$URL/-/tags" | grep -oE "tags/[^\"]+" | sed 's|tags/||' | grep -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" | sed -E 's/^[a-zA-Z0-9_-]*_([0-9])/\1/; s/^[vVrR]//' | tr '_' '.' | grep -E '^[0-9]+(\.[0-9]+)+$' | grep -E "^${2:-[0-9]}" | grep -E "[0-9]+.[02468]+.[0-9]+" | sort -V | tail -n 1
    fi
}

function wgnu_ver {
    curl -sL --connect-timeout 3 --max-time 5 "https://ftp.gnu.org/gnu/$1/" 2>/dev/null | sed -nE "s/.*href=[\"\x27]?$1-([0-9]+(\.[0-9]+)*)(\/|\.tar\.[a-z0-9]+|\.zip)[\"\x27]?.*/\1/p" | sort -V | tail -n 1
}

function wkap_ver {
	wget -T 5 -t 1 -c https://download.kde.org/stable/release-service -qO- | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
}

function wlgd_ver {
    wget --timeout=5 -t 1 -cqO- https://gitlab.gnome.org/World/gedit/$1/-/tags | grep "tags/"| grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | cut -d '/' -f 7 | head -n 1
}

function wlp_ver {
	wget --timeout=5 -t 1 -cqO- "$1/-/tags" | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -oE "tags/[^\"]+" | sed 's|tags/||' | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} -viE "alpha|beta|\.rc|rc[0-9]|\.9[0-9]" | sed -E 's/libpeas-//g' | grep '^1' | sort -V | tail -n 1
}

function wngnu_ver {
	curl -sL --connect-timeout 3 --max-time 5 "https://download.savannah.nongnu.org/releases/$1/" 2>/dev/null | grep -oE "$1-[0-9]+(\.[0-9]+)+(\.tar\.[a-z0-9]+|\.src\.tar\.gz|\.zip)" | sed -E "s/$1-([0-9]+(\.[0-9]+)+).*/\1/" | sort -V | tail -n 1
}

function wsf_ver {
    #wget --timeout=5 -t 1 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep "/tree" | grep -v "alpha\|beta\|rc" | grep -v "git-conv" | tail -n 1 | cut -d '/' -f 6
    wget --timeout=5 -t 1 -cqO- https://sourceforge.net/p/$1/ref/master/tags/ | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | tail -n 1
}

function wsp_ver {
	local repo_url=$(echo $1 | sed "s|/|%2F|g")
    wget --timeout=5 -t 1 -cqO- "https://gitlab.freedesktop.org/api/v4/projects/${repo_url}/releases?per_page=1" | grep -o '"tag_name":"[^"]*"' | grep -v "server" | sed -E 's|[a-z_-]+||g' | head -n 1 | cut -d'"' -f4
}

function wxfd_ver {
    wget --timeout=5 -t 1 -cqO- https://xorg.freedesktop.org/archive/individual/$1/ | grep "$2-" | grep '\.tar\.xz"' | cut -d '"' -f 2 | cut -d '-' -f 2 | sed 's/.tar.*$//g' | sort -V | tail -n 1
}
