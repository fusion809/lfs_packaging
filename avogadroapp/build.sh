#!/bin/bash
set -e
name=avogadroapp
_name=avogadro2
repo=OpenChemistry/$name
homepage="https://two.avogadro.cc"
description="An advanced molecular editor."
depends=(acl avogadrolibs brotli bzip2 cmake dbus double-conversion e2fsprogs eigen expat fast_float fmt fontconfig freetype gcc glew glib2 glibc graphite2 harfbuzz hdf5 hicolor-icon-theme icu jkqtplotter keyutils libaec libarchive libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon libxml2 lz4 mitkrb nlohmann-json openssl pcre2 pugixml qt6 ruby samba spglib systemd utf8cpp xz zlib zstd)
conflicts=(avogadro2-bin)
pip_depends=(cclib)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(-DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr)
cmaki "${cmake_options[@]}"
sudo sed -i \
    -e 's|^MimeType=.*$|MimeType=chemical/x-cjson;chemical/x-cml;chemical/x-xyz;chemical/x-cif;chemical/x-mmcif;chemical/x-pdb;chemical/pdby;chemical/x-mol2;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-mdl-rxnfile;chemical/x-mdl-rdfile;chemical/x-daylight-smiles;chemical/x-inchi;chemical/x-gaussian-input;chemical/x-macromodel-input;chemical/x-vmd;|' \
    /usr/share/applications/org.openchemistry.Avogadro2.desktop
sudo install -Dm644 "$PWD/../../cjson-mime.xml" /usr/share/mime/packages/avogadroapp-cjson.xml
sudo update-mime-database /usr/share/mime
sudo update-desktop-database /usr/share/applications
# Fix desktop config icon issue; without Avogadro2 doesn't have an icon shown in app menus
# under WhiteSur icon theme
sudo cp /usr/share/icons/hicolor/32x32/apps/org.openchemistry.Avogadro2.png /usr/share/pixmaps
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
