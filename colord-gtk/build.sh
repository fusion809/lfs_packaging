#!/bin/bash
set -e
name=colord-gtk
repo=hughsie/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 colord dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libepoxy libffi libgudev libjpeg-turbo libpciaccess libpng libwebp libxcb libxkbcommon libxml2 libxshmfence mesa orc pango pcre2 systemd tiff util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo lcms2 libdrm libseccomp libunwind llvm lm-sensors pixman spirv-tools)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/colord/releases/$filename
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
