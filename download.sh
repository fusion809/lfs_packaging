#!/bin/bash
function download_git {
	if [[ -n $2 ]]; then
		local name=$2
	else
		local name=$(echo $1 | rev | cut -d '/' -f 1 | rev | sed 's/.git//g')
	fi
	local URL=$1
	if ! [[ -d $name/.git ]]; then
		git clone $URL $name
	else
		git -C $name fetch --tags origin
	fi
}
function download_src {
	local URL=$1
	if [[ -n $2 ]]
	then
		local filename=$2
	else
		local filename=$(echo "$URL" | rev | cut -d '/' -f 1 | rev)
	fi

	if [[ -f $filename ]]
	then
		local valid=1

		case "$filename" in
			*.tar.gz|*.tgz)
				file -b "$filename" | grep -qE 'gzip compressed data' &&
					tar -tzf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*.tar.xz|*.txz)
				file -b "$filename" | grep -qE 'XZ compressed data' &&
					tar -tJf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*.tar.bz2|*.tbz2)
				file -b "$filename" | grep -qE 'bzip2 compressed data' &&
					tar -tjf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*.tar.zst|*.tzst)
				file -b "$filename" | grep -qE 'Zstandard compressed data' &&
					tar --zstd -tf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*.zip)
				file -b "$filename" | grep -qE 'Zip archive data' &&
					bsdtar -tf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*.rpm|*.deb)
				bsdtar -tf "$filename" >/dev/null 2>&1 || valid=0
				;;
			*)
				# Unknown format: at least make sure it isn't empty.
				[[ -s "$filename" ]] || valid=0
				;;
		esac

		if (( valid ))
		then
			printf '%s\n' "$filename already present and appears valid."
			return 0
		fi

		printf '%s\n' "$filename is invalid or incomplete; removing it."
		rm -f "$filename"
	fi

	if [[ -n $2 ]]
	then
		wget -c --progress=bar:force "$URL" -O "$filename"
	else
		wget -c --progress=bar:force "$URL"
	fi
}

function bb_download {
	local repo=$1
	local filename=$2
	download_src "https://bitbucket.org/$repo/downloads/$filename"
}

function fd_download {
	local name=$1
	local filename=$2
	download_src "https://www.freedesktop.org/software/$name/releases/$filename"
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

function ggn_download {
	local filename=$1
	local version=$(echo $1 | sed -E 's/\.tar\.[a-z0-9]+//g' | rev | cut -d '-' -f 1 | rev)
	local name=$(echo $1 | sed "s/-$version.tar.*//g")
	download_src "https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename"
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

function gla_download {
	local repo=$1
	local tag=$2
	local filename=$3
	if ! [[ -f $filename ]]; then
		wget -c --progress=bar:force https://gitlab.com/$repo/-/archive/$tag/$filename
	fi
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
	local filename=$1
	local version=$(echo $filename | sed -E 's/\.tar\.[a-z0-9]+//g' | rev | cut -d '-' -f 1 | rev)
	#local majVer=$(echo $version | cut -d '.' -f1-2)
	local majVer=$(echo $version | cut -d '.' -f 1)
	local name=$(echo $filename | sed "s/-$version.tar.*//g")
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
	local filename=$2
	local name=$(echo $filename | sed -E 's/-[0-9.]+.tar.*//g')
	local version=$(echo $filename | sed "s/$name-//g" | sed "s/.tar.*//g")
	local majVer=$(echo $version | cut -d '.' -f1-2)
	if [[ "$type" == "frameworks" ]]; then
		download_src "https://download.kde.org/stable/$type/$majVer/$filename"
	elif [[ "$type" == "app" ]]; then
		download_src "https://download.kde.org/stable/release-service/$version/src/$filename"
	else
		download_src "https://download.kde.org/stable/$name/$filename"
	fi
}

function ngnu_download {
	local name=$1
	local filename=$2
	download_src "https://download.savannah.nongnu.org/releases/$name/$filename"
}

function sf_download {
	local name=$1
	local direname=$2
	local filename=$3
	download_src "https://sourceforge.net/projects/$name/files/$name/$direname/$filename"
}

function spice_download {
	local filename=$1
	local name=$(echo $filename | sed -E 's/-v[0-9.]+.tar.*//g')
	local version=$(echo $filename | grep -oE "[0-9]+\.[0-9]+[\.]*[0-9]*")
	local repo=$(spice_repo $name)
	download_src "https://www.spice-space.org/download/releases/$filename"
}

function spice_git {
	local name=$(echo $repo | rev | cut -d '/' -f 1 | rev)
	local version=$(gfd_ver $repo)
	if ! [[ -d $name/.git ]]; then
		git clone --recursive https://gitlab.freedesktop.org/$repo.git
	fi
	git -C $name checkout v$version
}
function sw_download {
	local name=$1
	local filename=$2
	download_src "https://sourceware.org/pub/$name/$filename" || download_src "https://sourceware.org/pub/$name/releases/$filename"
}

function xfd_download {
	local type=$(get_xfd_type $1)
	local filename=$2
	download_src "https://xorg.freedesktop.org/archive/individual/$type/$filename"
}
