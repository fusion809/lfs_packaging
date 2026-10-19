#!/bin/bash
set -e
name=pymol
_name=pymol-open-source
repo=schrodinger/$_name
homepage="https://github.com/schrodinger/pymol-open-source"
description="Molecular visualization system."
version=$(gh_ver $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(freetype gcc glew msgpack-cxx glm pyqt6 netcdf netcdf-cxx python tcsh cmake desktop-file-utils mmtf-cpp msgpack-c)
pip_depends=(build installer wheel setptools numpy)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
wget -c https://github.com/schrodinger/pymol-open-source/commit/4f03162b41df3dd6df885400c45ffd54486ba3b7.patch -O upstream.patch
patch -Np1 -i upstream.patch
sed -i -e '/numpy/s/>.*"/"/g' pyproject.toml
	# both PEP517 instructions and legacy shims try to create the same binary
	sed -i -e '/pymol:launch/d' pyproject.toml
cat > /usr/share/applications/org.pymol.PyMOL.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=PyMOL Molecular Graphics System
Comment=Molecular visualization system on an Open Source foundation
Exec=pymol %F
Icon=pymol
Terminal=false
StartupNotify=false
Categories=Science;Chemistry;Education;
MimeType=chemical/x-pdb;chemical/pdby;chemical/x-mol2;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-xyz;chemical/x-macromodel-input;chemical/x-vmd;
EOF
sudo chmod +x /usr/share/applications/org.pymol.PyMOL.desktop
python -m build -wn
sudo python -m installer -d / dist/*.whl
sudo install -Dm0644 data/pymol/icons/icon2.svg "/usr/share/icons/hicolor/scalable/apps/pymol.svg"
sudo magick -density 300 /usr/share/icons/hicolor/scalable/apps/pymol.svg /usr/share/pixmaps/pymol.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
