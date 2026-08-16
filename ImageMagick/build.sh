#!/bin/bash
# Originally a book package; script written to overcome download failure
set -e
# Variable declarations
name=ImageMagick
version=$(gh_ver "$name/$name")
lfs_depends=(bzip2 expat fftw fontconfig freetype gcc glibc libffi libpng util-linux xz zlib zstd)
depends=(glib2 libICE libSM libX11 libXext libXrender libXt libwmf numactl pango pcre2)
blfs_depends=(brotli cairo fontconfig freetype fribidi graphite2 graphviz harfbuzz highway lcms2 libXau libXdmcp libaom libde265 libheif libjpeg-turbo libjxl libpng libraw libtiff libwebp libxcb libxml2 openjpeg pixman webkitgtk x264 x265 xorg-lib)
direname="$name-$version"
filename="$version.tar.gz"
# Fetch and unpack source
sudo rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ImageMagick/ImageMagick/archive/refs/tags/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
sudo rm -f /usr/lib/libMagickCore-7.Q16HDRI.so* /usr/lib/libMagickWand-7.Q16HDRI.so* /usr/lib/libMagick++-7.Q16HDRI.so*
configure_options=(
    --prefix=/usr     \
    --sysconfdir=/etc \
    --enable-hdri     \
    --with-modules    \
    --with-perl       \
    --disable-static
)

cmi "${configure_options[@]}"
sudo make DOCUMENTATION_PATH=/usr/share/doc/imagemagick-${version/-.*/} install
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
