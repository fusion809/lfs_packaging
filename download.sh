#!/bin/bash
function gnu_download {
	local name="$1"
	local filename="$2"
	if ! [[ -f $filename ]]; then
		wget -c --progress=bar:force https://ftpmirror.gnu.org/$name/$filename || wget -c --progress=bar:force https://ftp.gnu.org/gnu/$name/$filename
	fi
}
