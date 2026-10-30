#!/bin/bash
set -e
name=xdrawchem-git
_name=xdrawchem
repo=bryanherger/$_name
homepage="https://bryanherger.github.io/xdrawchem/"
description="Skeletal formula sketching software."
version=$(gh_com $repo)
depends=(boost brotli bzip2 coordgen dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libglvnd libpng libx11 libxau libxcb libxdmcp libxkbcommon maeparser mitkrb openbabel openssl pcre2 qt6 systemd xz zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_git "https://github.com/$repo.git"
cd $_name/$_name
sed -i -e "s|CMAKE_PROJECT_VERSION:STATIC=2.1.0|CMAKE_PROJECT_VERSION:STATIC=$version|g" CMakeLists.txt
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr
	-DCMAKE_BUILD_TYPE=Release
	-G Ninja)
cmaki "${cmake_options[@]}"
sudo rm /usr/share/applications/xdrawchem.desktop
sudo tee /usr/share/applications/io.github.bryanherger.xdrawchem.desktop << EOF
[Desktop Entry]
Name=XDrawChem
GenericName=Chemical Structure Editor
Comment=Draw and analyze chemical structures and reactions
Exec=xdrawchem %F
Icon=xdrawchem
Terminal=false
Type=Application
Categories=Science;Chemistry;Education;
MimeType=chemical/x-mdl-molfile;chemical/x-cml;chemical/x-xdrawchem;
Keywords=chemistry;molecule;structure;draw;
StartupNotify=true
StartupWMClass=xdrawchem
EOF
rm -rf build*
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
