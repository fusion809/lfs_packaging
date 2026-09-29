#!/bin/bash
set -e
name=openssl-julia
repo=julialang/julia
homepage="https://www.openssl.org"
description="OpenSSL libraries required by Julia."
version=$(gh_ver $repo)
depends=(glibc)
majVer=$(echo $version | cut -d '.' -f1-2)
filename="julia-$version-linux-x86_64.tar.gz"
direname="julia-$version"
download_src "https://julialang-s3.julialang.org/bin/linux/x64/$majVer/$filename"
tar xf "$filename"
sudo cp -r "$direname"/lib/julia/lib{ssl,crypto}.so.3 /usr/lib
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
