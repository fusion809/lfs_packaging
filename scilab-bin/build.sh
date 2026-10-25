#!/bin/bash
set -e
name=scilab-bin
_name=scilab
repo=$_name/$_name
homepage="https://scilab.org"
description="Open-source alternative to MATLAB."
version=$(gl_ver $repo)
depends=(alsa-lib at-spi2-core avahi brotli bzip2 cairo cups dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz java libdrm libepoxy libffi libglvnd libpng libseccomp libselinux libx11 libxau libxcb libxcomposite libxcrypt libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres libxtst libxxf86vm mesa nspr nss openssl pango pcre2 pixman systemd util-linux wayland zlib)
filename="$_name-$version.bin.x86_64-linux-gnu.tar.xz"
direname="$_name-$version"
download_src "https://www.scilab.org/download/$version/$filename"
srcdir=$PWD/$direname
unpk_enter "$filename" "$direname"
sudo rm -rf /opt/$_name
sudo cp -a "${srcdir}" "/opt/$_name"
sudo ln -sf "/opt/jdk/bin/java" "/opt/${_name}/thirdparty/java"
sudo install -Dm 644 share/applications/*.desktop "/usr/share/applications"
find share/icons/hicolor -type f -name '*.png' -print0 |
	while IFS= read -r -d '' file; do
        	dest="/usr/share/icons/hicolor/${file#share/icons/hicolor/}"
        	sudo install -D -m 644 -- "$file" "$dest" || exit
	done
sudo ln -sf /usr/share/icons/hicolor/256x256/apps/*.png /usr/share/pixmaps/
for _executable in scilab scilab-cli scilab-adv-cli scinotes xcos; do
	sudo rm -rf /usr/bin/$_executable
	sudo tee /usr/bin/$_executable > /dev/null << EOF
#!/usr/bin/env bash
set -u

SCI=/opt/scilab
JAVA="\$SCI/thirdparty/java"
JCEF="\$SCI/lib/thirdparty/jcef"

env \
    JAVA_HOME="\$JAVA" \
    JDK_HOME="\$JAVA" \
    LD_LIBRARY_PATH="\$JCEF:\$JAVA/lib:\$JAVA/lib/server" \
    "\$SCI/bin/$_executable"
EOF
sudo chmod +x /usr/bin/$_executable
done
sudo chown $USER /usr/share/applications/scilab.desktop
cat > /usr/share/applications/scilab.desktop << EOF
[Desktop Entry]
Comment=Scientific software package for numerical computations
Comment[fr]=Logiciel scientifique de calcul numérique
Comment[de]=eine Wissenschaftssoftware für numerische Berechnungen
Comment[ru]=Научная программа для численных расчётов
Exec=scilab -f %f
TryExec=/usr/bin/scilab
GenericName=Scientific Software Package
GenericName[fr]=Logiciel de calcul numérique
GenericName[de]=Wissenschaftssoftware
GenericName[ru]=Научный программный комплекс
Icon=scilab
MimeType=application/x-scilab-sci;application/x-scilab-sce;application/x-scilab-tst;application/x-scilab-dem;application/x-scilab-ssp;application/x-scilab-sod;application/x-scilab-xcos;application/x-scilab-zcos;application/x-scilab-ssp;application/x-scilab-bin;application/x-scilab-cosf;
Name=Scilab
StartupNotify=false
Terminal=false
Type=Application
Categories=Science;Math;
StartupWMClass=Scilab
Keywords=Science;Math;Numerical;Simulation
EOF
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
