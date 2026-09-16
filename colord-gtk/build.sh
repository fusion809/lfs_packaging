#!/bin/bash
set -e
name=colord-gtk
repo=hughsie/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo colord dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu lcms2 libdrm libepoxy libffi libgudev libjpeg-turbo libpciaccess libpng libseccomp libunwind libwebp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors mesa orc pango pcre2 pixman spirv-tools systemd tiff util-linux vulkan-loader wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.freedesktop.org/software/colord/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
            --buildtype=release \
            -D gtk4=true        \
            -D vapi=true        \
            -D docs=false       \
	    -D man=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
