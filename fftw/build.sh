#!/bin/bash
set -e
name=fftw
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.fftw.org/download.html | grep "fftw-[0-9.]+.tar.gz" -oE | sed 's/fftw-//g' | sed 's/.tar.gz//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/FFTW/fftw3.git | grep "fftw-[0-9.]+[-rc]*[0-9]" -oE | sed 's/fftw-//g' | grep -v "rc" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return	
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return	
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return	
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.fftw.org/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options1=(--prefix=/usr    \
            --enable-shared  \
            --disable-static \
            --enable-threads \
            --enable-sse2    \
            --enable-avx     \
	    --enable-avx2)
configure_options2=(--prefix=/usr    \
            --enable-shared  \
            --disable-static \
            --enable-threads \
            --enable-sse2    \
            --enable-avx     \
            --enable-avx2    \
	    --enable-float)
configure_options3=(--prefix=/usr    \
            --enable-shared  \
            --disable-static \
            --enable-threads \
	    --enable-long-double)
cmi "${configure_options1[@]}"
cmi "${configure_options2[@]}"
cmi "${configure_options3[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
