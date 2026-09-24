#!/bin/bash
set -e
name=gcr4
_name=gcr
repo=GNOME/$_name
version=$(gh_ver $repo $name)
depends=(brotli bzip2 cairo elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu lcms2 libdrm libelf libepoxy libffi libgcrypt libgpg-error libgudev libjpeg-turbo libpciaccess libpng libseccomp libsecret libtiff libunwind libwebp libx11 libxau libxcb libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa orc p11-kit pango pcre2 pixman spirv-tools systemd util-linux vulkan-loader wayland xz zlib zstd)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release \
	-D gtk_doc=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
