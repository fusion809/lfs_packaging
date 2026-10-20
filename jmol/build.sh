#!/bin/bash
set -e
name=jmol
_name=Jmol
url="https://sourceforge.net/projects/jmol/files/Jmol"
get_version() {
	local majMinVer=$(wget -T 5 -t 1 -cqO- $url | grep "Version [0-9.]+" -oE | head -n 1 | cut -d ' ' -f 2)
	local version=$(wget -T 5 -t 1 -cqO- $url/Version%20$majMinVer/ | grep "Jmol $majMinVer.*gz" | sed 's/.*Jmol //g' | cut -d '/' -f 1)
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$version" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://sourceforge.net/projects/jmol/"
description="Interactive 3D molecule viewer."
version=$(get_version)
filename="$_name-$version-binary.tar.gz"
direname="jmol-$version"
depends=(java)
download_src "$url/Version%20${version%.*}/Jmol%20$version/$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /usr/share/jmol
sudo cp *.jar /usr/share/jmol
sudo tee /usr/bin/jmol << 'EOF'
#!/bin/sh

# Collect -D & -m options as java arguments
command=java
while [ `echo $1 | egrep '^-D|^-m' | wc -l` != 0 ]; do
	command="$command $1"
	shift
done
JMOL_HOME=/usr/share/jmol
export PATH=$PATH:/opt/jdk/bin
if [ ! -e ${JMOL_HOME}/Jmol.jar ]; then
	echo "Jmol could not find its installed files."
	exit
fi

$command -Djmol.home="$JMOL_HOME" -jar ${JMOL_HOME}/Jmol.jar "$@"
EOF
sudo chmod +x /usr/bin/jmol
sudo tee /usr/share/applications/jmol.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Jmol
Comment=Molecular visualization system in Java
Exec=jmol %F
TryExec=/usr/bin/jmol
Icon=jmol
Terminal=false
StartupNotify=false
StartupWMClass=org-openscience-jmol-app-jmolpanel-JmolPanel
Categories=Science;Chemistry;Education;
MimeType=application/x-jmol;chemical/x-cif;chemical/x-cml;chemical/x-gaussian-input;chemical/x-mdl-molfile;chemical/x-mmcif;chemical/x-pdb;chemical/x-xyz
EOF
sudo wget -c "https://static.macupdate.com/products/28305/l/jmol-logo.png?v=1629318339" -O /usr/share/pixmaps/jmol.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
