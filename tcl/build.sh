#!/bin/bash
set -e
name=tcl
repo=tcltk/tcl
version=$(gh_ver $repo)
depends=(bash coreutils gcc gzip make tar zlib)
filename="${name}${version}-src.tar.gz"
docs_filename="${name}${version}-html.tar.gz"
direname="${filename/-src.tar.*/}"
download_src "https://sourceforge.net/projects/tcl/files/Tcl/$version/$filename"
download_src "https://sourceforge.net/projects/tcl/files/Tcl/$version/$docs_filename"
unpk_enter "$filename" "$direname"
SRCDIR=$(pwd)
cd unix
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD
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
oldVer=$(pkgver $name)
if [[ $version != $oldVer ]]; then
	grep -E '^/usr/lib/[a-z]+[0-9.]+$' /var/lib/custom-packages/tcl |
awk -F/ '
{
    dir = $NF
    prefix = dir
    sub(/[0-9].*$/, "", prefix)
    old[dir] = 1
    prefixes[dir] = prefix
}
END {
    for (dir in old) {
        prefix = prefixes[dir]
        cmd = "find /usr/lib -maxdepth 1 -type d -name \"" prefix "[0-9]*\" -printf \"%f\\n\" | sort -V | tail -n1"
        cmd | getline latest
        close(cmd)

        if (latest != dir)
            system("sudo rm -rvf -- /usr/lib/" dir)
    }
}'
fi
sudo su -c "make install 
chmod 644 /usr/lib/libtclstub$basever.a
chmod -v u+w /usr/lib/libtcl$basever.so
make install-private-headers
ln -sfv tclsh$basever /usr/bin/tclsh"
cd ..
sudo su -c "tar -xf ../$docs_filename --strip-components=1
mkdir -v -p /usr/share/doc/$name-$version
cp -v -r  ./html/* /usr/share/doc/$name-$version"
if [[ $version != $oldVer ]]; then
	sudo rm -rf /usr/share/doc/tcl-$oldVer
fi
cd ..
sudo rm -rf $filename $direname $docs_filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
