#!/bin/bash
set -e
name=kde-gtk-config
repo=KDE/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus double-conversion expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu kcolorscheme kconfig kcoreaddons kdbusaddons kdecoration kguiaddons ki18n kwindowsystem lcms2 libdrm libelf libepoxy libffi libpciaccess libpng libseccomp libX11 libxau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors mesa pango pcre2 pixman qt6 spirv-tools systemd util-linux wayland xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
