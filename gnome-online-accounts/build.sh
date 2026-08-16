#!/bin/bash
set -e
# Variable declaration
name=gnome-online-accounts
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(brotli cairo curl cyrus-sasl dconf fontconfig freetype fribidi gcr4 gdk-pixbuf glycin gnome-shell graphene graphite2 gsettings-desktop-schemas gst-plugins-bad gst-plugins-base gstreamer harfbuzz itstool json-glib keyutils lcms2 libXau libXdmcp libdrm libepoxy libfyaml libgcrypt libgpg-error libgudev libhandy libidn2 libjpeg-turbo libpng libpsl librest libseccomp libsecret libsoup libtiff libunistring libunwind libwebp libxcb libxkbcommon libxml2 libxmlb llvm lm-sensors nautilus nghttp2 p11-kit pixman spirv-tools vte vulkan-loader webkitgtk)
lfs_depends=(bzip2 e2fsprogs expat gcc gettext glibc libelf libffi openssl sqlite systemd util-linux xz zlib zstd)
depends=(elfutils glib2 libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libpciaccess libxshmfence mesa mitkrb openldap orc pango pcre2 wayland)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
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
	    -D man=false \
	    ..
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
