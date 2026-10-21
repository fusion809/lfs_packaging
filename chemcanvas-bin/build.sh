#!/bin/bash
set -e
name=chemcanvas-bin
user=ksharindam
_name=ChemCanvas
repo=$user/${name/-bin/}
homepage="https://ksharindam.github.io/chemcanvas/"
description="User-friendly skeletal formula drawing tool."
version=$(gh_ver $repo)
depends=(avahi brotli bzip2 coreutils cups dbus e2fsprogs expat fontconfig freetype fuse gcc glibc gmp graphite2 harfbuzz imagemagick libffi libglvnd libgpg-error libice libopenssl3 libpng libsm libx11 libxau libxcb libxcomposite libxcrypt libxdmcp openssl systemd util-linux wayland xz zlib)
filename="$_name-x86_64.AppImage"
direname="squashfs-root"
desk="io.github.$user.${name/-bin/}.desktop"
meta="io.github.$user.${name/-bin/}.metainfo.xml"
ghr_download "$repo" "v$version" "$filename"
sudo chmod +x *.AppImage
./$filename --appimage-extract
cd squashfs-root
sudo rm -rf /opt/${name/-bin/}
sudo mkdir -p /opt/${name/-bin/}
sudo cp -r usr/* /opt/${name/-bin/}
sudo tee /opt/${name/-bin/}/bin/${name/-bin/} << 'EOF'
#!/bin/bash
export RT=/opt/chemcanvas
export PATH=$PATH:$RT/bin
export LIB=$RT/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB
SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt \
REQUESTS_CA_BUNDLE=/etc/pki/tls/certs/ca-bundle.crt \
SSL_CERT_DIR=/etc/ssl/certs $LIB/chemcanvas/chemcanvas "$@"
EOF
sudo chmod +x /opt/${name/-bin/}/bin/${name/-bin/}
sudo ln -sf /opt/${name/-bin/}/bin/${name/-bin/} /usr/bin/
sudo ln -sf /opt/${name/-bin/}/share/applications/$desk /usr/share/applications/
sudo sed -i -e "s|Categories=Science;|Categories=Science;Education;Chemistry;\nStartupWMClass=chemcanvas|g" /opt/${name/-bin/}/share/applications/$desk
sudo rm -rf /opt/${name/-bin/}/share/icons/hicolor/[0-9]*x[0-9]*/
sudo ln -sf /opt/${name/-bin/}/share/metainfo/$meta /usr/share/metainfo/
sudo magick -density 300 /opt/${name/-bin/}/share/icons/hicolor/scalable/apps/${name/-bin/}.svg /opt/${name/-bin/}/share/pixmaps/${name/-bin/}.png
sudo ln -sf /opt/${name/-bin/}/share/pixmaps/${name/-bin/}.png /usr/share/pixmaps/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
