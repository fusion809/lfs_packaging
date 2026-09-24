#!/bin/bash
# Originally a book package; script written to overcome download failure
set -e
# Variable declarations
name=imagemagick
_name=ImageMagick
repo=$_name/$_name
version=$(gh_ver $repo | sed 's/\.\([0-9]*\)$/-\1/')
depends=(brotli bzip2 cairo expat fftw fontconfig fontconfig freetype freetype fribidi gcc glib2 glibc graphite2 graphviz harfbuzz highway lcms2 libaom libde265 libffi libheif libice libjpeg-turbo libjxl libpng libpng libraw libSM libtiff libwebp libwmf libX11 libXau libxcb libXdmcp libXext libxml2 libXrender libXt numactl openjpeg pango pcre2 pixman util-linux webkitgtk x264 x265 xorg-lib xz zlib zstd)
direname="$_name-$version"
filename="$version.tar.xz"
# Fetch and unpack source
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
echo $version | sudo tee /var/lib/custom-packages/$name
