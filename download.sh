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

function gnu_download {
	local name="$1"
	local filename="$2"
	local direname="${filename/.tar.*/}"
	download_src "https://ftpmirror.gnu.org/$name/$filename" || download_src "https://ftp.gnu.org/gnu/$name/$filename" || download_src "https://ftpmirror.gnu.org/$name/$direname/$filename"
}

function sf_download {
	local name=$1
	local direname=$2
	local filename=$3
	download_src "https://sourceforge.net/projects/$name/files/$name/$direname/$filename"
}