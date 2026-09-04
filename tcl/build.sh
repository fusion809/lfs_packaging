#!/bin/bash
set -e
name=tcl
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://github.com/tcltk/tcl/releases | grep "core-[0-9-]+" -oE | sed 's/core-//g' | tr '-' '.' | sed 's/\.$//g' | grep "^8\." | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/tcltk/tcl.git | grep -oE "core-8-[0-9]-[0-9]+$" | sed 's/core-//g' | tr '-' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
lfs_depends=(zlib gcc make tar gzip coreutils bash)
filename="${name}${version}-src.tar.gz"
docs_filename="${name}${version}-html.tar.gz"
direname="${filename/-src.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://sourceforge.net/projects/tcl/files/Tcl/$version/$filename
fi
if ! [[ -f $docs_filename ]]; then
	wget -c https://sourceforge.net/projects/tcl/files/Tcl/$version/$docs_filename
fi
sudo rm -rf $direname
tar xf $filename
cd $direname
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath
make -j$(nproc)

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

basever=$(echo $version | sed -E 's/\.[0-9]+$//'g)
sed -e "s|$SRCDIR/unix/pkgs/tdbc|/usr/lib/tdbc|" \
    -e "s|$SRCDIR/pkgs/tdbc[0-9.]+/generic|/usr/include|"     \
    -e "s|$SRCDIR/pkgs/tdbc[0-9.]+/library|/usr/lib/tcl$basever|"  \
    -e "s|$SRCDIR/pkgs/tdbc[0-9.]+|/usr/include|"             \
    -i pkgs/tdbc*/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl|/usr/lib/itcl|" \
    -e "s|$SRCDIR/pkgs/itcl[0-9.]+/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl[0-9.]+|/usr/include|"            \
    -i pkgs/itcl*/itclConfig.sh

unset SRCDIR
sudo su -c "make install 
chmod 644 /usr/lib/libtclstub$basever.a
chmod -v u+w /usr/lib/libtcl$basever.so
make install-private-headers
ln -sfv tclsh$basever /usr/bin/tclsh"
cd ..
sudo su -c "tar -xf ../$docs_filename --strip-components=1
mkdir -v -p /usr/share/doc/$name-$version
cp -v -r  ./html/* /usr/share/doc/$name-$version"
cd ..
sudo rm -rf $filename $direname $docs_filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
