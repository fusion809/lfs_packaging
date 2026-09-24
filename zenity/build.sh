#!/bin/bash
set -e
# Variable declaration
name=zenity
version=$(gn_ver zenity)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(brotli cairo curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf gettext glib2 glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 gzip harfbuzz hicolor-icon-theme lcms2 libadwaita libadwaita libdrm libelf libepoxy libffi libfyaml libgudev libidn2 libjpeg-turbo libpciaccess libpng libpsl libseccomp libtiff libunistring libunwind libwebp libx11 libxau libxcb libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa meson nghttp2 openldap openssl orc pango pango pcre2 pixman spirv-tools systemd tar util-linux vulkan-loader wayland webkitgtk zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
# Fetch source and unpack it
download_src "https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr \
	--buildtype=release \
	-D manpage=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
