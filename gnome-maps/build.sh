#!/bin/bash
set -e
# Variable declaration
name=gnome-maps
repo=GNOME/$name
version=$(gn_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(blueprint-compiler brotli bzip2 cairo dav1d desktop-file-utils e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf geoclue geocode-glib gettext gjs glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer harfbuzz json-glib keyutils lcms2 libadwaita libdrm libelf libepoxy libffi libgudev libgweather libidn2 libjpeg-turbo libpciaccess libpng libportal libpsl librest librsvg libseccomp libshumate libsoup libtiff libunistring libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxshmfence libxxf86vm llvm lm-sensors mesa mitkrb nghttp2 orc pango pcre2 pixman protobuf-c spirv-tools sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
# Fetch source and unpack it
#gn_download "$filename"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
