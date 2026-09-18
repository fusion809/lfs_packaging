#!/bin/bash
set -e
name=gnome-control-center
version=$(gn_ver $name)
depends=(accountsservice avahi brotli bzip2 cairo colord colord-gtk cracklib cups curl cyrus-sasl dbus e2fsprogs elfutils expat flac fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin gmp gnome-bluetooth gnome-desktop gnutls graphene graphite2 gsound gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz ibus icu jansson json-glib keyutils lame lcms2 libadwaita libcanberra libcap libdrm libelf libepoxy libevdev libffi libfyaml libgcrypt libgpg-error libgtop libgudev libidn2 libjpeg-turbo libnma libnotify libogg libpciaccess libpng libpsl libpwquality librest libseccomp libsecret libsndfile libsoup libtasn1 libtiff libunistring libunwind libvorbis libwacom libwebp libX11 libXau libxcb libxcrypt libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb modemmanager mpg123 nettle networkmanager nghttp2 nspr nss openldap openssl opus orc p11-kit pango pcre2 pixman polkit pulseaudio spirv-tools sqlite systemd udisks upower util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
