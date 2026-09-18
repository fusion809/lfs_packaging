#!/bin/bash
set -e
name=gnome-desktop
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu lcms2 libdrm libelf libepoxy libffi libgudev libjpeg-turbo libpciaccess libpng libseccomp libtiff libunwind libwebp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors mesa orc pango pcre2 pixman spirv-tools systemd util-linux vulkan-loader wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release \
	-D desktop_docs=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
