#!/bin/bash
set -e
name=lua
repo=$name/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.lua.org/ftp/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
cat > lua.pc << "EOF"
V=5.4
R=5.4.8

prefix=/usr
INSTALL_BIN=${prefix}/bin
INSTALL_INC=${prefix}/include
INSTALL_LIB=${prefix}/lib
INSTALL_MAN=${prefix}/share/man/man1
INSTALL_LMOD=${prefix}/share/lua/${V}
INSTALL_CMOD=${prefix}/lib/lua/${V}
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: Lua
Description: An Extensible Extension Language
Version: ${R}
Requires:
Libs: -L${libdir} -llua -lm -ldl
Cflags: -I${includedir}
EOF
sed -i -e "s|5.4.8|$version|g" -e "s|5.4|$majVer|g" lua.pc
make linux -j$(nproc)
sudo su -c "make INSTALL_TOP=/usr                \
     INSTALL_DATA="cp -d"            \
     INSTALL_MAN=/usr/share/man/man1 \
     TO_LIB=\"liblua.so liblua.so.$majVer liblua.so.$version\" \
     install &&

mkdir -pv                      /usr/share/doc/$direname &&
cp -v doc/*.{html,css,gif,png} /usr/share/doc/$direname &&

install -v -m644 -D lua.pc /usr/lib/pkgconfig/lua.pc"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
