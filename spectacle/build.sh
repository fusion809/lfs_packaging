#!/bin/bash
set -e
name=spectacle
# uver versions this wrong for some unknown reason
# despite correct homepage
description="KDE screenshot capture utility."
homepage="https://apps.kde.org/spectacle/"
repo=KDE/$name
version=$(gh_ver $repo)
depends=(acl attr breeze-icons brotli bzip2 curl cyrus-sasl dav1d dbus double-conversion e2fsprogs expat fdk-aac ffmpeg flac fontconfig freetype fribidi gcc giflib glib2 glibc graphite2 harfbuzz highway icu karchive kcodecs kcolorscheme kcompletion kconfig kconfigwidgets kcoreaddons kcrash kdbusaddons keyutils kglobalaccel kguiaddons ki18n kiconthemes kio kirigami kitemviews kjobwidgets knotifications kpipewire kquickimageeditor kservice kstatusnotifieritem kwidgetsaddons kwindowsystem kxmlgui lame layer-shell-qt leptonica libaom libarchive libass libcanberra libdrm libelf libepoxy libffi libglvnd libidn2 libjpeg-turbo libogg libpciaccess libpng libpsl libsndfile libtiff libtool libunistring libva libvorbis libvpx libwebp libx11 libxau libxcb libxdmcp libxext libxfixes libxkbcommon libxml2 libxshmfence libxxf86vm llvm lm-sensors lz4 mesa mitkrb mpg123 nghttp2 numactl openblas opencv openjpeg openldap openssl opus pcre2 pipewire prison pulseaudio purpose qt6 solid spirv-tools svt-av1 systemd tesseract tiff util-linux wayland webkitgtk x264 xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xdg-desktop-portal-kde xz zlib zstd zxing-cpp)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sed -e 's|OpenCV 4.7|OpenCV 5|' -i CMakeLists.txt
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
