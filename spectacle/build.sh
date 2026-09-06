#!/bin/bash
set -e
name=spectacle
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr brotli bzip2 curl cyrus-sasl double-conversion e2fsprogs expat fontconfig freetype gcc giflib glib2 glibc graphite2 harfbuzz icu keyutils kpipewire layer-shell-qt leptonica libX11 libXext libXfixes libXxf86vm libarchive libepoxy libffi libidn2 libpciaccess libpng libpsl libunistring libxkbcommon libxml2 libxshmfence lz4 mesa mitkrb nghttp2 openldap openssl pcre2 systemd tesseract util-linux wayland xz zlib zstd)
blfs_depends=(breeze-icons flac karchive kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kquickimageeditor kservice kstatusnotifieritem kwidgetsaddons kwindowsystem kxmlgui lame libXau libXdmcp libcanberra libdrm libjpeg-turbo libogg libsndfile libtiff libva libvorbis libwebp libxcb llvm lm-sensors mpg123 opencv openjpeg opus pipewire prison pulseaudio purpose qt6 solid spirv-tools webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil zxing-cpp)
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
