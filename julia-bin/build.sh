#!/bin/bash
set -e
_name=julia
name=$_name-bin
repo=julialang/$_name
version=$(gh_ver $repo)
depends=(gcc glibc zlib zstd)
majVer=$(echo $version | cut -d '.' -f1-2)
filename="$_name-$version-linux-x86_64.tar.gz"
direname="$_name-$version"
download_src "https://julialang-s3.julialang.org/bin/linux/x64/$majVer/$filename"
unpk_enter "$filename" "$direname"
sudo su -c "install -Dm755 bin/julia /usr/bin/
rm -rf /etc/julia
cp -r etc/julia /etc
rm -rf /usr/include/julia
cp -r include/julia /usr/include
rm -rf /usr/lib/julia
cp -r lib/julia /usr/lib
rm -rf /usr/lib/libjulia*
cp -r lib/libjulia* /usr/lib
rm -rf /usr/libexec/julia
cp -r libexec/julia /usr/libexec
rm -rf /usr/share/julia
cp -r share/julia /usr/share
cp -r share/applications/julia.desktop /usr/share/applications
rm -rf /usr/share/doc/julia-*
cp -r share/doc/julia /usr/share/doc/$direname
cp -r share/man/man1/julia.1 /usr/share/man/man1
cp -r share/metainfo/julia.appdata.xml /usr/share/metainfo
"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
