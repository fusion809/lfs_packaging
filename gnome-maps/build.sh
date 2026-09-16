#!/bin/bash
set -e
# Variable declaration
name=gnome-maps
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(blueprint-compiler brotli bzip2 cairo dav1d desktop-file-utils e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf geoclue geocode-glib gettext gjs glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer harfbuzz json-glib keyutils lcms2 libadwaita libdrm libelf libepoxy libffi libgudev libgweather libidn2 libjpeg-turbo libpciaccess libpng libportal libpsl librest librsvg libseccomp libshumate libsoup libtiff libunistring libunwind libwebp libX11 libXau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb nghttp2 orc pango pcre2 pixman protobuf-c spirv-tools sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
