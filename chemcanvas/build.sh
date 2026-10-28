#!/bin/bash
set -e
name=chemcanvas
repo=ksharindam/$name
homepage="https://github.com/ksharindam/chemcanvas"
description="User-friendly skeletal formula editor."
version=$(gh_com $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(python pyqt6)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /opt/chemcanvas-qt6
sudo pip3 install --no-build-isolation --prefix=/opt/chemcanvas-qt6 .
sudo tee /usr/bin/chemcanvas-qt6 << EOF
#!/bin/bash
export PATH=\$PATH:/opt/chemcanvas-qt6/bin
export LD_LIBRARY_PATH=\$PATH:/opt/chemcanvas-qt6/lib
export PYTHONPATH=/opt/chemcanvas-qt6/lib/python3.15/site-packages/chemcanvas:/opt/chemcanvas-qt6/lib/python3.15/site-packages
export QT_QPA_PLATFORM_PLUGIN_PATH=/opt/qt6/plugins/platforms
/opt/chemcanvas-qt6/bin/chemcanvas "\$@"
EOF
sudo chmod +x /usr/bin/chemcanvas-qt6
sudo tee /usr/share/applications/io.github.khsarindam.chemcanvas-qt6.desktop << EOF
[Desktop Entry]
Type=Application
Name=ChemCanvas Qt6
Comment=A 2D Chemical Drawing Tool
Exec=/usr/bin/chemcanvas-qt6 %f
TryExec=/usr/bin/chemcanvas-qt6
Icon=chemcanvas
Categories=Science;Education;Chemistry;
StartupWMClass=chemcanvas
MimeType=image/svg+xml;application/vnd.ksharindam.ccdx+xml;
Terminal=false
StartupNotify=false
EOF
if ! [[ -f /usr/share/pixmaps/chemcanvas.png ]] && [[ -f /opt/chemcanvas-qt6/share/pixmaps/chemcanvas.png ]]; then
	sudo ln -sf /opt/chemcanvas-qt6/share/pixmaps/chemcanvas.png /usr/share/pixmaps/
fi
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
