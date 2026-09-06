#!/bin/bash
set -e
name=kde-gtk-config
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu kdecoration libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libepoxy libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence mesa pango pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo kcolorscheme kconfig kcoreaddons kdbusaddons kguiaddons ki18n kwindowsystem lcms2 libXau libXdmcp libdrm libseccomp libxcb llvm lm-sensors pixman qt6 spirv-tools xcb-util-keysyms)
lfs_depends=(dbus libelf)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
