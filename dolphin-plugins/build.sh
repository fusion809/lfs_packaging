#!/bin/bash
set -e
name=dolphin-plugins
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 dbus dolphin double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kbookmarks kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kitemviews kjobwidgets knotifications kparts kservice ktexteditor ktextwidgets kwidgetsaddons kwindowsystem kxmlgui lame libcanberra libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb mpg123 openssl opus pcre2 pulseaudio qt6 solid sonnet spirv-tools syntax-highlighting systemd util-linux wayland webkitgtk xcb-util-keysyms xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
kde_download "app" "$filename"
unpk_enter "$filename" "$direname"
options=(
	-D CMAKE_INSTALL_PREFIX=/usr \
	-D CMAKE_BUILD_TYPE=Release \
	-D BUILD_TESTING=OFF \
	-W no-author
)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
