#!/bin/bash
set -e
# Variable declarations
name=graphicsmagick
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- http://www.graphicsmagick.org/ | grep "Released" | cut -d ' ' -f 1 | sed 's/.*<p>//g')
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
_archive="GraphicsMagick-$version"
depends=(bash brotli bzip2 coreutils freetype gcc glibc highway jasper lcms2 libaom libde265 libheif libice libjpeg-turbo libjxl libpng libsm libSM libtiff libtool libwebp libwmf libwmf libX11 libxau libxcb libXdmcp libxext libXext libxml2 littlecms numactl perl tar util-linux webkitgtk wget x264 x265 xz zlib zstd)
# Fetch and unpack source
sf_download "$name" "$version" "$_archive.tar.xz"
unpk_enter "$_archive.tar.xz" "$_archive"
# Compile and install
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
sed -e "s:freetype_config='':freetype_config='/usr/bin/pkg-config freetype2':g" -i configure
configure_options=(
	--prefix=/usr \
	--enable-shared \
	--with-modules \
	--with-perl \
	--with-quantum-depth=16 \
	--with-magick_plus_plus \
	--with-threads
)
cmi "${configure_options[@]}"
cd PerlMagick
sed -i -e "s:'LDDLFLAGS'  => \"\(.*\)\":'LDDLFLAGS'  => \"-L${pkgdir}/usr/lib \1\":" Makefile.PL
perl Makefile.PL INSTALLDIRS=vendor PREFIX=/usr DESTDIR="${pkgdir}"
sed -i -e "s/LDLOADLIBS =/LDLOADLIBS = -lGraphicsMagick/" Makefile
maki
oldVer=$(pkgver $name)
if [[ $oldVer != $version ]]; then
	sudo rm -rf /usr/{lib,share}/GraphicsMagick-$oldVer
fi
# Cleanup and add to database
cd ..
sudo rm -rf $_archive $_archive.tar.xz
echo $version | sudo tee /var/lib/custom-packages/$name
