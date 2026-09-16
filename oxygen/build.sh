#!/bin/bash
set -e
name=oxygen
repo=KDE/$name
version=$(gh_ver $repo)
depends=(breeze-icons brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig frameworkintegration freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kcmutils kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kdecoration keyutils kglobalaccel kguiaddons ki18n kiconthemes kitemviews kwidgetsaddons kwindowsystem kxmlgui libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb openssl pcre2 qt6 spirv-tools systemd util-linux wayland xcb-util-keysyms xz zlib zstd)
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
