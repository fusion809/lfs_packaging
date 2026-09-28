#!/bin/bash
set -e
name=gnome-software
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl appstream avahi brotli bzip2 curl cyrus-sasl dbus dconf e2fsprogs elfutils expat flatpak fontconfig freetype fribidi fwupd gcc gdk-pixbuf glib2 glibc glycin gpgme graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils libarchive libassuan libdrm libepoxy libffi libfyaml libglvnd libgpg-error libgudev libidn2 libjpeg-turbo libpng libpsl libseccomp libsoup libunistring libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxmlb libxrandr libxrender lz4 mesa mitkrb nghttp2 openldap openssl orc ostree packagekit pango pcre2 pixman polkit sqlite systemd tiff util-linux vulkan-loader wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mkdir build
cd build
meson setup --prefix=/usr --buildtype=release -D man=false .. || echo "Meson setup failed, but this is expected; applying patch"
cd ..
if [[ -f subprojects/malcontent/accounts-service/meson.build ]]; then
	sed -i -e "1s|'com.endlessm.ParentalControls.policy',||g" subprojects/malcontent/accounts-service/meson.build
fi
mni --prefix=/usr --buildtype=release -D man=false
cd ../..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
