#!/bin/bash

function ghl_ver {
	local URL="https://github.com/$1.git"
	if [[ "$1" == "avahi/avahi" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep "tags/v[0-9.]+[-rc]*[0-9]*" -E | sed 's|.*tags/v||g' \
		| sort -V | tail -n 1
	elif [[ "$1" == "openpmix/prrte" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" | grep "^3" | sort -V | tail -n 1
	elif [[ "$1" == "openpmix/openpmix" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" | grep "^5" | sort -V | tail -n 1
	elif [[ "$1" == "GNOME/librsvg" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" \
		| grep -oE "[0-9]+.[0-9]+.[0-8][0-9]*" | sort -V | tail -n 1
	elif [[ "$1" == "KhronosGroup/Vulkan-Loader" ]] \
	|| [[ "$1" == "KhronosGroup/Vulkan-Headers" ]]; then
        timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" \
		| grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
	elif [[ "$1" == "GNOME/gcr3" ]]; then
		local URL="https://github.com/GNOME/gcr.git"
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" | grep -oE "3\.[0-8][0-9]*\.[0-9]+" \
		| sort -V | tail -n 1
	elif [[ "$1" == "GNOME/libgtop" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" | grep -oE "2\.[0-8][0-9]*\.[0-9]+" \
		| sort -V | tail -n 1
	elif [[ "$1" == "GNOME/gvfs" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" \
		| grep -oE "[0-9]+\.[0-9][02468]\.[0-8][0-9]*" | sort -V | tail -n 1
	elif [[ "$1" == "GNOME/at-spi2-core" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep -oE "refs/tags/[0-9]+\.[0-9]*[02468]+\.[0-8][0-9]*" \
		| cut -d '/' -f 3 | sort -V | tail -n 1
	elif echo $1 | grep "KDE" &> /dev/null; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep -oE "refs/tags/[v]*[0-9]+\.[0-9]+\.[0-8][0-9]*" \
		| cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1 
	elif echo $1 | grep hyfetch &> /dev/null; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep -oE "refs/tags/[0-9]+\.[0-9]+\.[0-8][0-9]*" | cut -d '/' -f 3 \
		| sed 's/^v//g' | sort -V | tail -n 1 
	elif [[ "$1" == "tcltk/tcl" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep "core-[0-9-]+$" -oE | sed 's/^core-//g' | tr '-' '.' | sort -V \
		| tail -n 1
	elif [[ "$1" == "golang/go" ]]; then
		timeout 5 git ls-remote --tags --refs "$URL" \
		| grep "tags/go[0-9.]+" -oE | sed 's/.*go//g' | sort -V | tail -n 1
	else
		timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
		| cut -d '/' -f 3 | grep -viE "alpha|beta|rc|dev|snapshot|init" \
		| sed -E 's/^[a-zA-Z0-9-]*-//g; s/^[vVrR][-_]?//g' | tr '_' '.' \
		| grep -E "^[0-9]+(\.[0-9]+)+$" | tr '-' '.' | sort -V | tail -n 1
	fi
}

function ght_ver {
	if [[ "$1" == "avahi/avahi" ]]; then
		wget -T 5 -t 1 -cqO- https://github.com/$1/tags \
		| grep -E "tags/v[0-9.]+[-rc]*[0-9]*.tar.gz" | sed 's|.*tags/v||g' \
		| sed 's/.tar.gz.*//g' | sort -V | tail -n 1
		return
	elif [[ "$1" == "golang/go" ]]; then
		wget -T 5 -t 1 -cqO- https://github.com/golang/go/tags | grep "tag/go[0-9.]+" -oE | sed 's/.*go//g' | sort -V | tail -n 1
	fi
	if [[ "$1" == "GNOME/gcr3" ]]; then
		local repo="GNOME/gcr"
	else
		local repo="$1"
	fi
    local latest_url
    local latest_tag
    local version

    latest_url=$(curl --max-time 10 --connect-timeout 3 -Ls \
        -o /dev/null -w '%{url_effective}' \
        "https://github.com/$repo/releases/latest")

    latest_tag=$(grep -oP '/tag/\K.*' <<< "$latest_url")

    # Only use the GitHub "latest release" result if its tag is stable.
    if [[ "$1" != "GNOME/at-spi2-core" ]] && [[ -n "$latest_tag" ]] && \
	[[ "$1" != "GNOME/gvfs" ]] && [[ "$1" != "GNOME/gcr3" ]] && \
	[[ $repo != "GNOME/librsvg" ]] && ! echo $repo | grep KDE &> /dev/null &&
	    [[ $repo != "KhronosGroup/Vulkan-Loader" ]] &&
            [[ $repo != "KhronosGroup/Vulkan-Headers" ]] &&
	! grep -qiE '(alpha|beta|rc|pre|preview|dev|snapshot|init|[0-9]+\.[0-9]+\.9[0-9])' <<< "$latest_tag"; then

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

	local URL="https://github.com/$repo/tags.atom"
    # Special handling for libvpx.
    if [[ "$repo" == "webmproject/libvpx" ]]; then
        wget -T 5 -t 1 -cqO- "$URL" | grep -oE 'link.*v[0-9.]+' \
		| sed 's/.*v//' | head -n 1
        return
    elif [[ "$repo" == "GNOME/librsvg" || "$repo" == "GNOME/gjs" ]]; then
		wget -T 5 -t 1 -cqO- "$URL" | grep -v "beta" \
		| grep -oE "[0-9]+\.[0-9]+\.[0-8]" | sort -V | tail -n 1
		return
	elif [[ "$1" == "GNOME/gcr3" ]]; then
		wget -T 5 -t 1 -cqO- "$URL" | grep -v "beta" \
		| grep -oE "3\.[0-8][0-9]*\.[0-9]" | sort -V | tail -n 1
		return
	elif [[ "$1" == "GNOME/gvfs" ]]; then
		wget -T 5 -t 1 -cqO- "$URL" | grep -v "beta" \
		| grep -oE "[0-9]+\.[0-9][02468]\.[0-9]+" | sort -V | tail -n 1
		return
    elif [[ "$repo" == "KhronosGroup/Vulkan-Loader" ]] || \
	[[ "$repo" == "KhronosGroup/Vulkan-Headers" ]]; then
		wget -T 5 -t 1 -cqO- "$URL" | grep -v "beta" \
        | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
		return
    elif [[ "$repo" == "GNOME/at-spi2-core" ]]; then
	    wget -T 5 -t 1 -cqO- "$URL" \
		| grep -oE "[0-9]+\.[0-9]*[02468]+\.[0-8][0-9]*" | sort -V | tail -n 1
		return
	elif echo $repo | grep "KDE" &> /dev/null; then
	    wget -T 5 -t 1 -cqO- "$URL" | grep -oE "[0-9]+\.[0-9]+\.[0-8][0-9]*" \
		| sort -V | tail -n 1
	    return
    fi

    # Fall back to finding the highest stable tag.
    wget --timeout=5 -t 1 -cqO- \
        "$URL" |
        grep '<title>' |
        grep -vE '<title>Tags from |(alpha|beta|rc|pre|preview|dev|snapshot|init)' |
        sed -nE \
            "s/.*<title>//;
             s/^${repo#*/}[[:space:]_-]*//i;
             s/^[^0-9]*([0-9]+([._-][0-9]+)*).*/\1/p" |
        tr '_' '.' | tr '-' '.' |
        sort -V |
        tail -n 1
}

function gkap_ver {
	local URL="https://github.com/KDE/$1.git"
	timeout 5 git ls-remote --tags --refs "$URL" \
	| grep -oE "[0-9]+\.[02468]+\.[0-9]+" | sort -V | tail -n 1
}

function goct_ver {
	local URL="https://github.com/gnu-octave/octave.git"
    timeout 5 git ls-remote --tags --refs "$URL" 2>/dev/null \
	| grep "release-" | cut -d '/' -f 3 | sed 's/release-//g' \
	| sed 's/-/./g' | sort -V | tail -n1
}
