#!/bin/bash
set -e
name=sqlite
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -qO- https://sqlite.org/download.html |
    grep -o 'sqlite-autoconf-[0-9]*\.tar\.gz' |
    head -n1 |
    grep -o '[0-9]*' |
    head -n1)
	ver_check "$up_ver" "$inst_ver" && return
	local base_ver=$(ghl_ver $name/$name)
	local majVer=$(echo $base_ver | cut -d '.' -f 1)
	local minVer=$(echo $base_ver | cut -d '.' -f 2)
	local patchVer=$(echo $base_ver | cut -d '.' -f 3)
	local git_ver=$(echo "${majVer}${minVer}0${patchVer}00")
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-autoconf-$version.tar.gz"
direname="${filename/.tar.*/}"
docs_filename="$name-doc-$version.zip"
if ! [[ -f $filename ]]; then
	wget -c https://sqlite.org/$(date +"%Y")/$filename
fi
if ! [[ -f $docs_filename ]]; then
	wget -c https://sqlite.org/$(date +"%Y")/$docs_filename
fi
rm -rf $direname
tar xf $filename
cd $direname
python3 -m zipfile -e ../$docs_filename .
configure_options=(--prefix=/usr     \
            --disable-static  \
            --enable-fts{4,5} \
            CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
                      -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
                      -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
		      -D SQLITE_SECURE_DELETE=1")
./configure "${configure_options[@]}"
make LDFLAGS.rpath="" -j$(nproc)
sudo make install
sudo cp -v -R $name-doc-$version -T /usr/share/doc/$name-$(ghl_ver sqlite/sqlite)
cd ..
rm -rf $filename $direname $docs_filename
echo $version > /var/lib/custom-packages/$name
