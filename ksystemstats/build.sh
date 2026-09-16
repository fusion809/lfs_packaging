#!/bin/bash
set -e
name=ksystemstats
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu kauth kconfig kcoreaddons kcrash keyutils ki18n kio kservice libdrm libelf libffi libksysguard libnl libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb networkmanager networkmanager-qt nspr nss openssl pcre2 qt6 solid spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
