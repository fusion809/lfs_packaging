#!/bin/bash
set -e
name=tcl
version=$(gh_ver tcltk/tcl | sed 's/-/./g')
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
rm -rf $direname
tar xf $filename
cd $direname
SRCDIR=$(pwd)
cd unix
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --disable-rpath
make

sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

basever=$(echo $version | sed -E 's/\.[0-9]+$//'g)
sed -e "s|$SRCDIR/unix/pkgs/tdbc|/usr/lib/tdbc|" \
    -eE "s|$SRCDIR/pkgs/tdbc[0-9.]+/generic|/usr/include|"     \
    -eE "s|$SRCDIR/pkgs/tdbc[0-9.]+/library|/usr/lib/tcl$basever|"  \
    -eE "s|$SRCDIR/pkgs/tdbc[0-9.]+|/usr/include|"             \
    -i pkgs/tdbc*/tdbcConfig.sh

sed -eE "s|$SRCDIR/unix/pkgs/itcl|/usr/lib/itcl|" \
    -eE "s|$SRCDIR/pkgs/itcl[0-9.]+/generic|/usr/include|"    \
    -eE "s|$SRCDIR/pkgs/itcl[0-9.]+|/usr/include|"            \
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
rm -rf $filename $direname $docs_filename
echo "$version" > /var/lib/custom-packages/$name
