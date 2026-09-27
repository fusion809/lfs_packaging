#!/bin/bash
set -e
name=julia
description="A high-level, high-performance, dynamic, scientific computing-oriented programming language."
homepage="http://julialang.org"
repo=julialang/$name
version=$(gh_ver $repo)
depends=(blas-lapack gcc glibc gmp mpfr nghttp2 libssh2 openssl pcre2 suitesparse zlib zstd)
filename="$name-$version.tar.gz"
direname="$name-$version"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make_options=(
    prefix=/usr
    bindir=/usr/bin
    sysconfdir=/etc
    libexecdir=/usr/libexec
    USE_SYSTEM_PCRE=1
    USE_SYSTEM_BLAS=1
    USE_SYSTEM_LAPACK=1
    USE_SYSTEM_GMP=1
    USE_SYSTEM_MPFR=1
    USE_SYSTEM_LIBSUITESPARSE=1
    USE_SYSTEM_OPENSSL=1
    USE_SYSTEM_ZSTD=1
    USE_SYSTEM_ZLIB=1
    USE_SYSTEM_NGHTTP2=1
    USE_SYSTEM_LIBSSH2=1)
arch_patch "$name" "system-zstd.patch"
maki "${make_options[@]}"
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
