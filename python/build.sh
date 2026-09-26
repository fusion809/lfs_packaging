#!/bin/bash
set -e
name=python
homepage="https://www.python.org/"
description="The Python programming language"
get_version() {
    local inst_ver=$(pkgver $name)
    local lfs_vers=$(lfs_ver $name)
    local up_ver=$(wget -T 5 -t 1 -cqO- https://www.python.org/downloads/source/ | grep -E "[0-9]+\.[0-9]+\.[0-9]+" | grep "a href" | head -n 1 | sed 's/.*Python //g' | sed 's/<.*//g')
    ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
    local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/python/cpython.git | grep -E "refs/tags/v[0-9]+\.[0-9]+\.[0-9]+$" | cut -d '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
    ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
    fver $name $inst_ver
}

version=$(get_version)
filename="Python-$version.tar.xz"
direname="${filename/.tar.*/}"
docs_filename="python-${version}-docs-html.tar.bz2"
depends=(gcc glibc make ncurses tar wget xz)
download_src "https://www.python.org/ftp/python/$version/$filename"
download_src "https://www.python.org/ftp/python/doc/$version/$docs_filename"
unpk_enter "$filename" "$direname"
gap_patches Python
configure_options=(--prefix=/usr          \
    --enable-shared        \
    --with-system-expat    \
    --enable-optimizations \
    --without-static-libpython)
cmi "${configure_options[@]}"
sudo su -c "install -v -dm755 /usr/share/doc/$direname/html

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/$direname/html \
    -xvf ../$docs_filename"
cd ..
sudo rm -rf $direname $filename "$docs_filename"
echo $version | sudo tee /var/lib/custom-packages/$name
