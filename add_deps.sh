#!/bin/bash

# add_deps: Examines binaries and libraries of a package in ~/lfs_packaging,
# maps dependencies to /var/lib/{custom,book}-packages, and adds them to
# `depends`, `lfs_depends`, or `blfs_depends` in that package's build.sh.
function add_deps {
	if [[ -z "$1" ]]; then
		echo "Usage: add_deps <package_name> [--dry-run] [--verbose]"
		return 1
	fi
	python3 ~/lfs_packaging/add_deps.py "$@"
}

function add_deps_new {
	new_pkgs=$(git ls-files --others --exclude-standard | grep "build.sh" | cut -d '/' -f 1)
	while read -r pkg; do
    	add_deps "$pkg"
	done <<< "$new_pkgs"
}