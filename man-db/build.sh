#!/bin/bash
set -e
name=man-db
homepage="https://gitlab.com/man-db/man-db"
description="Utility for reading man pages."
repo=$name/$name
version=$(gl_ver $repo)
depends=(bash coreutils gcc gdbm glibc libpipeline libseccomp make tar xz zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
#download_src "https://download.savannah.gnu.org/releases/$name/$filename"
gla_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# GitLab's source archive omits the gnulib checkout required by bootstrap.
# Set the mirror in bootstrap.conf so it survives build helpers that clear
# the environment before invoking bootstrap. The commit remains pinned there.
sed -i '/^GNULIB_REVISION=/a GNULIB_URL=https://github.com/coreutils/gnulib.git' \
    bootstrap.conf
configure_options=(--prefix=/usr                         \
            --docdir=/usr/share/doc/$direname \
            --sysconfdir=/etc                     \
            --disable-setuid                      \
            --enable-cache-owner=bin              \
            --with-browser=/usr/bin/lynx          \
            --with-vgrind=/usr/bin/vgrind         \
            --with-grap=/usr/bin/grap)
cmi "${configure_options[@]}"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
