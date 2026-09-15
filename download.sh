#!/bin/bash
function gha_download {
	local repo=$1
	local tag=$2
	local filename=$3
	if [[ -f $filename ]]; then
		wget -c --progress=bar:force https://github.com/$repo/archive/$tag.tar.gz -O $filename
	fi
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
	if [[ -f $filename ]]; then
		wget -c --progress=bar:force https://github.com/$repo/releases/download/$direname/$filename
	fi
}

function gnu_download {
	local name="$1"
	local filename="$2"
	local direname="${filename/.tar.*/}"
	if ! [[ -f $filename ]]; then
		wget -c --progress=bar:force https://ftpmirror.gnu.org/$name/$filename || wget -c --progress=bar:force https://ftp.gnu.org/gnu/$name/$filename || wget -c --progress=bar:force https://ftpmirror.gnu.org/$name/$direname/$filename
	fi
}
