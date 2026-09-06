#!/bin/bash
set -e
name=kirigami-addons
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcolorscheme kconfig kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa mitkrb openssl pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(breeze-icons libXau libXdmcp libdrm libxcb llvm lm-sensors qt6 spirv-tools)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/$name/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release               -D BUILD_TESTING=OFF)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
