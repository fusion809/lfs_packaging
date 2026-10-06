#!/bin/bash
set -e
# Variable declaration
name=libadwaita
description="Building blocks for modern adaptive GNOME applications."
homepage="https://gitlab.gnome.org/GNOME/libadwaita"
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(acl appstream at-spi2-core brotli bzip2 cairo colord curl cyrus-sasl dav1d dbus e2fsprogs elfutils evolution-data-server expat flac fontconfig freetype fribidi gcc gcr4 gdk-pixbuf gettext gjs glib2 glibc glycin gnome-autoar gnome-desktop gnome-shell graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils lame lcms2 libarchive libcanberra libdisplay-info libdrm libei libelf libepoxy libevdev libffi libfyaml libgcrypt libglvnd libgpg-error libgudev libical libidn2 libinput libjpeg-turbo libogg libpciaccess libpng libpsl librsvg libseccomp libsecret libsndfile libsoup libtiff libtool libunistring libunwind libvorbis libwacom libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxmlb libxrandr libxrender libxres libxshmfence libxxf86vm llvm lm-sensors lua lz4 mesa mitkrb mpg123 mtdev mutter ncurses networkmanager nghttp2 nspr nss openldap openssl opus orc p11-kit pango pcre2 pipewire pixman polkit pulseaudio readline sassc spirv-tools sqlite startup-notification systemd tiff util-linux vala vulkan-loader wayland webkitgtk xcb-util xz zlib zstd)
# Fetch source and unpack it
gn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
mni --prefix=/usr --buildtype=release
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
