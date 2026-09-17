#!/bin/bash
function download_src {
	local URL=$1
	if [[ -n $2 ]]; then
		local filename=$2
	else
		local filename=$(echo $URL | rev | cut -d '/' -f 1 | rev)
	fi	
	if ! [[ -f $filename ]] && [[ -n $2 ]]; then
		wget -c --progress=bar:force $URL -O $filename
	elif ! [[ -f $filename ]]; then
		wget -c --progress=bar:force $URL
	else
		printf '%s\n' "$filename already present."
	fi
}

function bb_download {
	local repo=$1
	local filename=$2
	if ! [[ -f $filename ]]; then
		wget -c --progress=bar:force https://bitbucket.org/$repo/downloads/$filename
	fi
}

function gfd_download {
	local repo="$1"
	local tag="$2"
	local filename="$3"
	download_src "https://gitlab.freedesktop.org/$repo/-/archive/$tag/$filename"
}

function gfdr_download {
	local repo="$1"
	local tag="$2"
	local filename="$3"
	download_src "https://gitlab.freedesktop.org/$repo/-/releases/$tag/download/$filename"
}

function gha_download {
	local repo=$1
	local tag=$2
	local filename=$3
	download_src "https://github.com/$repo/archive/$tag.tar.gz" "$filename"
}

function ghr_download {
	local repo=$1
	if [[ -n "$3" ]]; then
		local direname=$2
		local filename=$3
	else
		local filename=$2
		local direname="${2/.tar.*/}"
	fi
	download_src "https://github.com/$repo/releases/download/$direname/$filename"
}

function gng_download {
	local name="$1"
	local version="$2"
	if [[ -n "$3" ]]; then
		local filename="$3"
	else
		local filename="$name-$version.tar.xz"
	fi
	download_src "https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename"
}

function gn_download {
	local name="$1"
	local version="$2"
	local majVer=$(echo $version | cut -d '.' -f 1)
	if [[ -n "$3" ]]; then
		local filename="$3"
	else
		local filename="$name-$version.tar.xz"
	fi
	download_src "https://download.gnome.org/sources/$name/$majVer/$filename"
}

function gnu_download {
	local name="$1"
	local filename="$2"
	local direname="${filename/.tar.*/}"
	download_src "https://ftpmirror.gnu.org/$name/$filename" || download_src "https://ftp.gnu.org/gnu/$name/$filename" || download_src "https://ftpmirror.gnu.org/$name/$direname/$filename"
}

function kde_download {
	local type=$1
	local version=$2
	local majVer=$(echo $version | cut -d '.' -f1-2)
	local filename=$3
	if ! [[ -f $filename ]]; then
		wget -c --progress=bar:force https://download.kde.org/stable/$type/$majVer/$filename
	fi
}
function sf_download {
	local name=$1
	local direname=$2
	local filename=$3
	download_src "https://sourceforge.net/projects/$name/files/$name/$direname/$filename"
}

function sw_download {
	local name=$1
	local filename=$2
	download_src "https://sourceware.org/pub/$name/$filename"
}

function xfd_download {
	local type=$(get_xfd_type $1)
	local filename=$2
	download_src "https://xorg.freedesktop.org/archive/individual/$type/$filename"
}