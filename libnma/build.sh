#!/bin/bash
set -e
name=libnma
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus elfutils expat fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu lcms2 libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libdrm libepoxy libffi libgcrypt libgpg-error libgudev libjpeg-turbo libpciaccess libpng libseccomp libunwind libwebp libxcb libxkbcommon libxml2 libxshmfence lm-sensors mesa networkmanager nspr nss orc p11-kit pango pcre2 pixman spirv-tools systemd tiff util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(llvm)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D gtk_doc=false    \
      -D libnma_gtk4=true \
      -D mobile_broadband_provider_info=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
