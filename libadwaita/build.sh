#!/bin/bash
set -e
# Variable declaration
name=libadwaita
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
lfs_depends=(bzip2 expat gcc gettext glibc libelf libffi openssl systemd util-linux xz zlib zstd)
blfs_depends=(brotli cairo curl cyrus-sasl fontconfig freetype fribidi gdk-pixbuf glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz lcms2 libXau libXdmcp libdrm libepoxy libfyaml libgudev libidn2 libjpeg-turbo libpng libpsl libseccomp libtiff libunistring libunwind libwebp libxcb libxkbcommon libxml2 libxmlb llvm lm-sensors nghttp2 pixman sassc spirv-tools vala vulkan-loader webkitgtk)
depends=(appstream elfutils glib2 libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libpciaccess libxshmfence mesa openldap orc pango pcre2 wayland)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/libadwaita/$(echo $version | sed 's/.[0-9]$//g')/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup --prefix=/usr       \
            --buildtype=release \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
