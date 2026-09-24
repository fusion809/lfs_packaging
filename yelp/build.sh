#!/bin/bash
set -e
name=yelp
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo curl cyrus-sasl dav1d e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz highway icu keyutils lcms2 libadwaita libaom libavif libdrm libelf libepoxy libffi libfyaml libgcrypt libgpg-error libgudev libidn2 libjpeg-turbo libjxl libpciaccess libpng libpsl libseccomp libsecret libsoup libtasn1 libtiff libunistring libunwind libwebp libX11 libxau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libxslt libXxf86vm llvm lm-sensors mesa mitkrb nghttp2 openldap openssl orc pango pcre2 pixman spirv-tools sqlite svt-av1 systemd util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr 
	--buildtype=release
)
mni "${options[@]}"
sudo update-desktop-database
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
