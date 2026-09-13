#!/bin/bash
set -e
name=xorg-server
repo=$name/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.x.org/pub/individual/xserver/ | grep "xorg-server-[0-9]+\.[0-9]+\.[0-9]+" -oE | grep -v "\.99" | sed 's/xorg-server-//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/xorg/xserver.git | grep "refs/tags/xorg-server-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/.*-//g' | grep -v ".99" | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 expat freetype gcc glibc icu libX11 libXext libXfont2 libXxf86vm libepoxy libffi libfontenc libpciaccess libpng libxml2 libxshmfence mesa nettle systemd xz zlib zstd)
blfs_depends=(libXau libXdmcp libdrm libtirpc libxcb libxcvt llvm lm-sensors pixman spirv-tools)
lfs_depends=(dbus libelf)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Kernel config options required
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.x.org/pub/individual/xserver/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
meson_options=(--prefix=/usr --localstatedir=/var -D glamor=true -D xkb_output_dir=/var/lib/xkb)
mni "${meson_options[@]}"
sudo mkdir -pv /etc/X11/xorg.conf.d
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
