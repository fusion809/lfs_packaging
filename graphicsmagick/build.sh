#!/bin/bash
set -e
# Variable declarations
name=graphicsmagick
get_version() {
	local up_ver=$(wget -cqO- http://www.graphicsmagick.org/ | grep "Released" | cut -d ' ' -f 1 | sed 's/.*<p>//g')
	ver_check "$up_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}
version=$(get_version)
_archive="GraphicsMagick-$version"
depends=(libICE libSM libX11 libXext libwmf numactl)
lfs_depends=(bash bzip2 coreutils gcc glibc libtool perl tar util-linux xz zlib zstd)
blfs_depends=(brotli freetype highway jasper lcms2 libXau libXdmcp libaom libde265 libheif libjpeg-turbo libjxl libpng libsm libtiff libwebp libwmf libxcb libxext libxml2 littlecms webkitgtk wget x264 x265)
# Fetch and unpack source
if ! [[ -f $_archive.tar.xz ]]; then
	wget -c https://downloads.sourceforge.net/project/$name/$name/$version/$_archive.tar.xz
fi
sudo rm -rf $_archive
tar xf $_archive.tar.xz
# Compile and install
cd $_archive
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
# Cleanup and add to database
cd ..
sudo rm -rf $_archive*
echo $version > /var/lib/custom-packages/$name
