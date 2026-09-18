#!/bin/bash
set -e
# Variable declarations
name=fastfetch
repo=fastfetch-cli/$name
depends=(bash coreutils gcc glibc yyjson zlib
pulseaudio libxcb libxrandr sqlite)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"

# Get the source
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
mkdir -p build
cd build
cmake .. \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_BUILD_TYPE='RelWithDebInfo' \
		-DBUILD_FLASHFETCH='OFF' \
		-DBUILD_TESTS='ON' \
		-DENABLE_SQLITE3='ON' \
		-DENABLE_RPM='OFF' \
		-DENABLE_IMAGEMAGICK6='OFF' \
		-DENABLE_SYSTEM_YYJSON='ON' \
		-DPACKAGES_DISABLE_APK='ON' \
		-DPACKAGES_DISABLE_DPKG='ON' \
		-DPACKAGES_DISABLE_EMERGE='ON' \
		-DPACKAGES_DISABLE_EOPKG='ON' \
		-DPACKAGES_DISABLE_GUIX='ON' \
		-DPACKAGES_DISABLE_LINGLONG='ON' \
		-DPACKAGES_DISABLE_LPKG='ON' \
		-DPACKAGES_DISABLE_LPKGBUILD='ON' \
		-DPACKAGES_DISABLE_OPKG='ON' \
		-DPACKAGES_DISABLE_PACSTALL='ON' \
		-DPACKAGES_DISABLE_PALUDIS='ON' \
		-DPACKAGES_DISABLE_PKG='ON' \
		-DPACKAGES_DISABLE_PKGTOOL='ON' \
		-DPACKAGES_DISABLE_RPM='ON' \
		-DPACKAGES_DISABLE_SORCERY='ON' \
		-DPACKAGES_DISABLE_XBPS='ON' \
		-Wno-dev \
	-DCMAKE_C_FLAGS:STRING="-O2 -fPIC" \
	-DCMAKE_CXX_FLAGS:STRING="-O2 -fPIC"
cmake --build . --target fastfetch
sudo make install
cd ../..
rm -rf $filename $direname
# Add to database
echo $version | sudo tee /var/lib/custom-packages/$name
