#!/bin/bash
set -e
# Variable declaration
name=libadwaita
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(appstream brotli bzip2 cairo curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf gettext glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz lcms2 libdrm libelf libepoxy libffi libfyaml libgudev libidn2 libjpeg-turbo libpciaccess libpng libpsl libseccomp libtiff libunistring libunwind libwebp libX11 libXau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa nghttp2 openldap openssl orc pango pcre2 pixman sassc spirv-tools systemd util-linux vala vulkan-loader wayland webkitgtk xz zlib zstd)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/libadwaita/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
mni --prefix=/usr --buildtype=release
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
