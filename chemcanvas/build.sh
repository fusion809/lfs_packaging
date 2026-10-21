#!/bin/bash
set -e
name=chemcanvas
user=ksharindam
_name=ChemCanvas
repo=$user/$name
homepage="https://ksharindam.github.io/chemcanvas/"
description="User-friendly skeletal formula drawing tool."
version=$(gh_ver $repo)
depends=(imagemagick fuse coreutils)
filename="$_name-x86_64.AppImage"
direname="squashfs-root"
desk="io.github.$user.$name.desktop"
meta="io.github.$user.$name.metainfo.xml"
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x *.AppImage
./$filename --appimage-extract
cd squashfs-root
sudo rm -rf /opt/$name
sudo mkdir -p /opt/$name
sudo cp -r usr/* /opt/$name
sudo tee /opt/$name/bin/$name << 'EOF'
#!/bin/bash
export RT=/opt/chemcanvas
export PATH=$PATH:$RT/bin
export LIB=$RT/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB
SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt \
REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt \
SSL_CERT_DIR=/etc/ssl/certs $LIB/chemcanvas/chemcanvas "$@"
EOF
sudo chmod +x /opt/$name/bin/$name
sudo ln -sf /opt/$name/bin/$name /usr/bin/
sudo ln -sf /opt/$name/share/applications/$desk /usr/share/applications/
sudo sed -i -e "s|Categories=Science;|Categories=Science;Education;Chemistry;\nStartupWMClass=chemcanvas|g" /opt/$name/share/applications/$desk
sudo rm -rf /opt/$name/share/icons/hicolor/[0-9]*x[0-9]*/
sudo ln -sf /opt/$name/share/metainfo/$meta /usr/share/metainfo/
sudo magick -density 300 /opt/$name/share/icons/hicolor/scalable/apps/$name.svg /opt/$name/share/pixmaps/$name.png
sudo ln -sf /opt/$name/share/pixmaps/$name.png /usr/share/pixmaps/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
