#!/bin/bash
set -e
name=plasma-sdk
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu karchive kauth kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpackage kparts kservice ksvg ktexteditor kwidgetsaddons kwindowsystem kxmlgui libICE libSM libX11 libXext libXfixes libXxf86vm libffi libpciaccess libplasma libpng libxkbcommon libxml2 libxshmfence mesa mitkrb openssl pcre2 plasma-activities plasma5support solid sonnet syntax-highlighting systemd util-linux wayland xz zlib zstd)
blfs_depends=(breeze-icons flac ki18n lame libXau libXdmcp libcanberra libdrm libogg libsndfile libvorbis libxcb llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools webkitgtk xcb-util-keysyms)
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
