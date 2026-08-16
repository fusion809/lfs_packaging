#!/bin/bash
set -e
# Variable declaration
name=gnome-maps
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(bzip2 e2fsprogs expat gcc gettext glibc libelf libffi sqlite systemd util-linux xz zlib zstd)
depends=(elfutils glib2 libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libpciaccess libxshmfence mesa mitkrb orc pango pcre2 wayland)
blfs_depends=(blueprint-compiler brotli cairo dav1d desktop-file-utils fontconfig freetype fribidi gdk-pixbuf geoclue geocode-glib gjs glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer harfbuzz json-glib keyutils lcms2 libXau libXdmcp libadwaita libdrm libepoxy libgudev libgweather libidn2 libjpeg-turbo libpng libportal libpsl librest librsvg libseccomp libshumate libsoup libtiff libunistring libunwind libwebp libxcb libxkbcommon libxml2 llvm lm-sensors nghttp2 pixman protobuf-c spirv-tools vulkan-loader)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
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
echo $version > /var/lib/custom-packages/$name
