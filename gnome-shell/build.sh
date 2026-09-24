#!/bin/bash
set -e
name=gnome-shell
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl at-spi2-core brotli bzip2 cairo colord dbus e2fsprogs elfutils evolution-data-server expat flac fontconfig freetype fribidi gcc gcr4 gdk-pixbuf gjs glib2 glibc glycin gnome-autoar gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils lame lcms2 libarchive libcanberra libdisplay-info libdrm libei libelf libepoxy libevdev libffi libgcrypt libgpg-error libgudev libical libidn2 libinput libjpeg-turbo libogg libpciaccess libpng libpsl libseccomp libsecret libsndfile libsoup libtiff libunistring libunwind libvorbis libwacom libwebp libx11 libxau libxcb libxcomposite libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors lua lz4 mesa mitkrb mpg123 mtdev mutter ncurses networkmanager nghttp2 nspr nss openssl opus orc p11-kit pango pcre2 pipewire pixman polkit pulseaudio readline spirv-tools sqlite startup-notification systemd util-linux vulkan-loader wayland webkitgtk xcb-util xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -e '/(ICalProperty/s/ICalProperty/const &/' \
    -i src/calendar-server/gnome-shell-calendar-server.c
options=(
	--prefix=/usr
	--buildtype=release
	-D tests=false
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
