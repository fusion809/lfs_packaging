#!/bin/bash

function pkgver {
        find /var/lib/{book,custom}-packages -type f -name "$1" -exec sh -c '
    for file; do
        head -n1 "$file"
    done
' sh {} +
}

# Echoes $1 and returns 0 if it looks like a valid version string, otherwise returns 1.
function ver_check {
	if [[ -n "$2" ]]; then
		local inst_ver=$(pkgver $2)
	    if echo "$1" | grep -qE "[0-9.]+" &> /dev/null &&  [[ "$(printf '%s\n%s\n' "$inst_ver" "$1" | sort -V | head -n1)" == "$inst_ver" ]]; then
			echo "$1"
			return 0
		fi
	else
		if echo "$1" | grep -qE "[0-9.]+" &> /dev/null; then
			echo "$1"
			return 0
		fi
	fi
	return 1
}