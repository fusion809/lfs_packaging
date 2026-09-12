#!/bin/bash
set -e
year=$(date +"%Y")
name=texlive
get_version() {
	if [[ -n "$year" ]]; then
		year=$(date +"%Y")
	fi
	if wget -T 5 -t 1 -cqO- https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/ | grep "$year/" &> /dev/null; then
		local up_ver=$(wget -T 5 -t 1 -cqO- https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/ | grep "texlive-$year.*-source.tar.xz" | grep -v "sha512" | cut -d '-' -f 2)
	else
		year=$(($year-1))
	fi
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 expat fontconfig freetype gcc glib2 glibc gmp graphite2 harfbuzz icu libICE libSM libX11 libXau libXaw libXdmcp libXext libXi libXmu libXpm libXrender libXt libpaper libpng libxcb mpfr pcre2 util-linux zlib)
blfs_depends=(cairo pixman)
filename="$name-$version-source.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$filename
fi
mf_filename="$name-$version-texmf.tar.xz"
if ! [[ -f $mf_filename ]]; then
	wget -c https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$mf_filename
fi
ex_filename="$name-$version-extra.tar.xz"
if ! [[ -f $ex_filename ]]; then
	wget -c https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$ex_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
export TEXARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/$/-linux/') &&
TEXLIVE_PREFIX=/opt/texlive/$year
options=(CXX="g++ -std=gnu++17" -C            \
    --prefix=$TEXLIVE_PREFIX                      \
    --bindir=$TEXLIVE_PREFIX/bin/$TEXARCH         \
    --datarootdir=$TEXLIVE_PREFIX                 \
    --includedir=$TEXLIVE_PREFIX/include          \
    --infodir=$TEXLIVE_PREFIX/texmf-dist/doc/info \
    --libdir=$TEXLIVE_PREFIX/lib                  \
    --mandir=$TEXLIVE_PREFIX/texmf-dist/doc/man   \
    --disable-native-texlive-build                \
    --disable-static --enable-shared              \
    --disable-dvisvgm                             \
    --with-system-cairo                           \
    --with-system-fontconfig                      \
    --with-system-freetype2                       \
    --with-system-gmp                             \
    --with-system-graphite2                       \
    --with-system-harfbuzz                        \
    --with-system-icu                             \
    --with-system-libpaper                        \
    --with-system-libpng                          \
    --with-system-mpfr                            \
    --with-system-pixman                          \
    --with-system-zlib                            \
    --with-banner-add=" - BLFS")
mkdir texlive-build
cd texlive-build
../configure "${options[@]}"
make -j$(nproc)
sudo su -c "make install-strip &&
make texlinks      &&
mkdir -pv                                $TEXLIVE_PREFIX/tlpkg/TeXLive/ &&
install -v -m644 ../texk/tests/TeXLive/* $TEXLIVE_PREFIX/tlpkg/TeXLive/ &&
tar -xf ../../$ex_filename -C $TEXLIVE_PREFIX/tlpkg --strip-components=2
tar -xf ../../$mf_filename -C $TEXLIVE_PREFIX --strip-components=1
mktexlsr &&
fmtutil-sys --all
ln -svf $TEXLIVE_PREFIX/lib/libkpathsea.so{,.6} /usr/lib
ln -svf $TEXLIVE_PREFIX/applications/* /usr/share/applications"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
