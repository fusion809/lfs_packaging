#!/bin/bash
set -e
name=spectacle
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 curl cyrus-sasl dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc giflib glib2 glibc graphite2 harfbuzz icu karchive kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpipewire kquickimageeditor kservice kstatusnotifieritem kwidgetsaddons kwindowsystem kxmlgui lame layer-shell-qt leptonica libarchive libcanberra libdrm libelf libepoxy libffi libidn2 libjpeg-turbo libogg libpciaccess libpng libpsl libsndfile libtiff libunistring libva libvorbis libwebp libX11 libXau libxcb libXdmcp libXext libXfixes libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors lz4 mesa mitkrb mpg123 nghttp2 opencv openjpeg openldap openssl opus pcre2 pipewire prison pulseaudio purpose qt6 solid spirv-tools systemd tesseract util-linux wayland webkitgtk xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xz zlib zstd zxing-cpp)
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
