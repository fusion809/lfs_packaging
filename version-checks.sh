#!/bin/bash

function pkgver {
    if [[ -n $2 ]]; then
        find /var/lib/{book,custom}-packages -type f -name "$1" -exec sh -c '
            lines=$1
            shift
            for file; do
                head -n "$lines" "$file" | tail -n 1
            done
        ' sh "$2" {} + | sort -V | tail -n 1
    else
        find /var/lib/{book,custom}-packages -type f -name "$1" -exec sh -c '
            for file; do
                head -n 1 "$file"
            done
        ' sh {} + | sort -V | tail -n 1
    fi
}

function newest_ver {
	printf '%s\n' "$@" | sort -V | tail -n 1
}

# Fed three arguments:
# version that should be the latest, installed version and some reference version that may newer than the installed version
# If $1 is defined and not older than $2 and $3, print it.
# If $3 is defined and not equal to $2, print it. 
function ver_check {
    newest=$(newest_ver "${3:-$2}" "$2" "$1")
    if [[ $1 =~ ^[0-9.+a-z-]+ && "$newest" == "$1" ]]; then
	echo "$1"
	return 0
    # Print 
    elif [[ "$3" =~ ^[0-9.a-z]+ && "$newest" != "$2" && "$newest" == "$3" ]]; then
        echo "$3"
        return 0
    fi
    return 1
}
