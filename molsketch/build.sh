#!/bin/bash
set -e
name=molsketch
_name=Molsketch
repo=$name/code
homepage="https://sourceforge.net/projects/molsketch/"
description="2D molecule editor."
depends=(boost brotli bzip2 coordgen dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon maeparser mitkrb openbabel openssl pcre2 qt6 systemd xz zlib zstd)
version=$(sf_ver $repo)
filename="$_name-$version-src.tar.gz"
direname="${filename/-src.tar.*/}"
download_src "https://sourceforge.net/projects/molsketch/files/Molsketch/$filename"
unpk_enter "$filename" "$direname"
patch -p1 < "$PWD/../../molsketch/open-files-after-startup.patch"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
    -D MSK_INSTALL_LIBS64=/lib \
    -D MSK_QT6=ON \
    -D CMAKE_CXX_FLAGS="$CXXFLAGS -ffile-prefix-map=$srcdir=." \
    -G Ninja \
    -W no-dev)
cmaki "${cmake_options[@]}"
sudo sed -i \
    -e 's|^Exec=molsketch$|Exec=molsketch %f|' \
    -e 's|^MimeType=.*$|MimeType=application/x-molsketch;application/x-molsketch-molecule;chemical/x-cif;chemical/x-mmcif;chemical/x-cml;chemical/x-daylight-smiles;chemical/x-inchi;chemical/x-mdl-molfile;chemical/x-mdl-rdfile;chemical/x-mdl-rxnfile;chemical/x-mdl-sdfile;chemical/x-mol2;chemical/x-pdb;chemical/pdby;chemical/x-xyz;chemical/x-macromodel-input;chemical/x-vmd;|' \
    -e '/^StartupWMClass=/d' \
    -e 's|^Categories=.*$|Categories=Science;Chemistry;Education;\nStartupWMClass=net.sourceforge.molsketch|' \
    /usr/share/applications/molsketch.desktop
sudo install -Dm644 "$PWD/../../formats.xml" /usr/share/mime/packages/molsketch-formats.xml
sudo update-mime-database /usr/share/mime
sudo update-desktop-database /usr/share/applications
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
