#!/bin/bash
set -e
# Variable declaration
name=gnome-online-accounts
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(brotli bzip2 cairo curl cyrus-sasl dconf e2fsprogs elfutils expat fontconfig freetype fribidi gcc gcr4 gdk-pixbuf gettext glib2 glibc glycin gnome-shell graphene graphite2 gsettings-desktop-schemas gst-plugins-bad gst-plugins-base gstreamer harfbuzz itstool json-glib keyutils lcms2 libadwaita libdrm libelf libepoxy libffi libfyaml libgcrypt libgpg-error libgudev libhandy libidn2 libjpeg-turbo libpciaccess libpng libpsl librest libseccomp libsecret libsoup libtiff libunistring libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxmlb libxrandr libxrender libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb nautilus nghttp2 openldap openssl orc p11-kit pango pcre2 pixman spirv-tools sqlite systemd util-linux vte vulkan-loader wayland webkitgtk xz zlib zstd)
# Fetch source and unpack it
gn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
    --prefix=/usr       \
    --buildtype=release \
	-D man=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
