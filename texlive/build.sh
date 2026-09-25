#!/bin/bash
set -e
year=$(date +"%Y")
name=texlive
get_version() {
	if [[ -n "$year" ]]; then
		year=$(date +"%Y")
	fi
	local lfs_vers=$(lfs_ver $name)
	if wget -T 5 -t 1 -cqO- https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/ | grep "$year/" &> /dev/null; then
		local up_ver=$(wget -T 5 -t 1 -cqO- https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/ | grep "texlive-$year.*-source.tar.xz" | grep -v "sha512" | cut -d '-' -f 2)
	else
		year=$(($year-1))
	fi
	local inst_ver=$(pkgver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
    local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 cairo expat fontconfig freetype gcc glib2 glibc gmp graphite2 harfbuzz icu libice libpaper libpng libSM libx11 libxau libxaw libxcb libxdmcp libxext libxi libxmu libxpm libxrender libxt mpfr pcre2 pixman util-linux zlib)
filename="$name-$version-source.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$filename"
mf_filename="$name-$version-texmf.tar.xz"
download_src "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$mf_filename"
ex_filename="$name-$version-extra.tar.xz"
download_src "https://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$year/$ex_filename"
unpk_enter "$filename" "$direname"
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
