#!/bin/bash
set -e
name=marvin
depends=(java)
homepage="http://www.chemaxon.com/"
description="Intuitive application for chemical sketching and visualization."
get_version() {
	local ver=26.1.4
	local aur_ver=$(aurver $name)
	local inst_ver=$(pkgver $name)
	ver_check "$ver" "$inst_ver" "$aur_ver" && return
	local nix_ver=$(nixver $name)
	ver_check "$nix_ver" "$inst_ver" "$aur_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(java)
filename="${name}_linux_$version.rpm"
download_src "https://dl.chemaxon.com/marvin/$version/$filename"
bsdtar xf "$filename"
cat > /usr/share/applications/MarvinSketch.desktop << EOF
#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=MarvinSketch
Exec=/usr/bin/msketch %f
Icon=MarvinSketch
MimeType=text/xml;text/plain;chemical/x-cml;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-mol2;chemical/x-pdb;chemical/x-xyz;chemical/x-mdl-rdfile;chemical/x-mdl-rxnfile;chemical/x-inchi;
Categories=Education;Science;Chemistry;
StartupWMClass=com-install4j-runtime-launcher-UnixLauncher
EOF
cat > /usr/share/applications/MarvinView.desktop << EOF
#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=MarvinView
Exec=/usr/bin/mview %f
Icon=MarvinView
MimeType=text/xml;text/plain;chemical/x-cml;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-mol2;chemical/x-pdb;chemical/x-xyz;chemical/x-mdl-rdfile;chemical/x-mdl-rxnfile;chemical/x-inchi;
Categories=Education;Science;Chemistry;
StartupWMClass=com-install4j-runtime-launcher-UnixLauncher
EOF
sudo chmod +x /usr/share/applications/Marvin*.desktop
sudo su -c "mkdir -p /opt/chemaxon/marvinsuite/.install4j
cp -R opt/chemaxon/marvinsuite/.install4j/{*.uuid,*.utf8,*.png,*.ico,*.jar,*.conf} /opt/chemaxon/marvinsuite/.install4j
cp -R opt/chemaxon/marvinsuite/* /opt/chemaxon/marvinsuite
ln -sf /opt/chemaxon/marvinsuite/.install4j/Marvin*.png /usr/share/pixmaps/
ln -sf /opt/chemaxon/marvinsuite/bin/cxcalc /usr/bin/cxcalc
ln -sf /opt/chemaxon/marvinsuite/bin/cxtrain /usr/bin/cxtrain
ln -sf /opt/chemaxon/marvinsuite/bin/molconvert /usr/bin/molconvert
ln -sf /opt/chemaxon/marvinsuite/bin/msketch /usr/bin/msketch
ln -sf /opt/chemaxon/marvinsuite/bin/mview /usr/bin/mview"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
