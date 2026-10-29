#!/bin/bash
set -e
name=avogadro2-bin
_name=Avogadro2
repo=OpenChemistry/avogadroapp
homepage="https://two.avogadro.cc/"
description="Advanced open-soure molecule editor and informatics and 3D visualization app."
version=$(gh_ver $repo)
conflicts=(avogadroapp avogadrolibs openbabel)
filename="$_name-x86_64.AppImage"
direname="squashfs-root"
depends=(fuse)
ghr_download "$repo" "release-$version" "$filename"
chmod +x $filename
./$filename --appimage-extract
cd $direname
sudo cp -av usr/. /usr/
cd ../
sudo sed -i \
    -e 's|^MimeType=.*$|MimeType=chemical/x-cjson;chemical/x-cml;chemical/x-xyz;chemical/x-cif;chemical/x-mmcif;chemical/x-pdb;chemical/pdby;chemical/x-mol2;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-mdl-rxnfile;chemical/x-mdl-rdfile;chemical/x-daylight-smiles;chemical/x-inchi;chemical/x-gaussian-input;chemical/x-macromodel-input;chemical/x-vmd;|' \
    /usr/share/applications/org.openchemistry.Avogadro2.desktop
sudo install -Dm644 "$PWD/cjson-mime.xml" /usr/share/mime/packages/avogadroapp-cjson.xml
sudo update-mime-database /usr/share/mime
sudo update-desktop-database /usr/share/applications
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
