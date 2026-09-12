#!/bin/bash
set -e
name=shared-mime-info
repo=$name/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://gitlab.freedesktop.org/xdg/shared-mime-info/-/tags | grep "[0-9]+\.[0-9]+\.[0-9]+" -oE | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs  https://gitlab.freedesktop.org/xdg/shared-mime-info.git | cut -d '/' -f 3 | sed 's/Release-//g' | sed 's/-/./g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(gcc glib2 glibc icu libxml2 pcre2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr         \
            --buildtype=release   \
            -D update-mimedb=true \
            -D build-tests=false  \
	    -D build-spec=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
