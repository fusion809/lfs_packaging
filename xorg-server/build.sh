#!/bin/bash
set -e
name=xorg-server
repo=xorg/xserver
version=$(gfd_ver $repo $name)
depends=(brotli bzip2 dbus expat freetype gcc glibc icu libdrm libelf libepoxy libffi libfontenc libpciaccess libpng libtirpc libX11 libxau libxcb libxcvt libXdmcp libXext libXfont2 libxml2 libxshmfence libXxf86vm llvm lm-sensors mesa nettle pixman spirv-tools systemd xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Kernel config options required
download_src "https://www.x.org/pub/individual/xserver/$filename"
unpk_enter "$filename" "$direname"
gap_patches $name
meson_options=(
	--prefix=/usr \
	--localstatedir=/var \
	-D glamor=true \
	-D xkb_output_dir=/var/lib/xkb
)
mni "${meson_options[@]}"
sudo mkdir -pv /etc/X11/xorg.conf.d
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
