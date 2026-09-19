#!/bin/bash
set -e
name=kirigami-addons
repo=KDE/$name
version=$(gh_ver $repo)
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcolorscheme kconfig kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
#filename="$name-$version.tar.xz"
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
#if ! [[ -f $filename ]]; then
#	wget -c --progress=bar:force https://download.kde.org/stable/$name/$filename
#fi
gha_download $repo v$version $filename
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_TESTING=OFF
)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
