#!/bin/bash
set -e
# Variable declarations
name=fastfetch
depends=(yyjson)
lfs_depends=(bash coreutils gcc glibc zlib)
blfs_depends=(cmake dbus dconf ImageMagick 
pulseaudio libxcb libxrandr sqlite)
version=$(gh_ver "fastfetch-cli/fastfetch")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"

# Get the source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/fastfetch-cli/fastfetch/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
echo $version > /var/lib/custom-packages/$name
