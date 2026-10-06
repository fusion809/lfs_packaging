#!/bin/bash
set -e
year=$(date +"%Y")
name=texlive
homepage="https://tug.org/texlive/"
description="TeX Live - a comprehensive TeX distribution."
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
depends=(brotli bzip2 cairo curl cyrus-sasl dbus double-conversion expat fontconfig freetype gcc glib2 glibc gmp gpgme gpgmepp graphite2 harfbuzz icu lcms2 libassuan libffi libglvnd libgpg-error libice libidn2 libjpeg-turbo libpaper libpng libpsl libsm libunistring libwebp libx11 libxau libxaw libxcb libxdmcp libxext libxi libxkbcommon libxmu libxpm libxrender libxt mpfr nghttp2 nspr nss openjpeg openldap openssl pcre2 pixman qt6 systemd tiff util-linux xz zlib zstd)
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
prevyear=$(ls /opt/texlive/[0-9]* -ld | sed 's|.*/opt/texlive/||g' | grep -v $year)
while read -r oldyear
do
	sudo rm -rf /opt/texlive/$oldyear
	echo "If upgrading texlive, remember to reinstall dvisvgm against " \
	     "the new texlive."
done <<< $prevyear
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
sudo su -c "export PATH=$PATH:$TEXLIVE_PREFIX/bin/x86_64-linux
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TEXLIVE_PREFIX/lib
export TEXLIVE_PREFIX=$TEXLIVE_PREFIX
make install-strip &&
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
