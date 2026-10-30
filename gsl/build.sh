#!/bin/bash
set -e
name=gsl
homepage="http://www.gnu.org/software/gsl/"
description="GNU Scientific Library."
version=$(gnu_ver $name)
depends=(blas-lapack-git gcc glibc openblas sagemath)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
LDFLAGS+=' -lcblas' cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
