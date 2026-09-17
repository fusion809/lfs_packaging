#!/bin/bash
set -e
name=vscode
version=$(git ls-remote --tags https://github.com/microsoft/vscode.git | grep -oP 'refs/tags/\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
depends=(alsa-lib at-spi2-core avahi brotli bzip2 cairo cups curl cyrus-sasl dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz highway keyutils lcms2 libaom libavif libdrm libelf libepoxy libffi libgcrypt libgpg-error libidn2 libjpeg-turbo libjxl libpng libpsl libseccomp libsecret libsoup libtasn1 libunistring libunwind libwebp libX11 libXau libxcb libXcomposite libxcrypt libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxkbfile libxml2 libXrandr libXrender libXres libxslt mesa mitkrb nghttp2 nspr nss openldap openssl orc pango pcre2 pixman sqlite svt-av1 systemd util-linux wayland webkitgtk xz zlib zstd)
filename="code_${version}_amd64.deb"
download_src "https://update.code.visualstudio.com/${version}/linux-deb-x64/stable" "$filename"
mkdir -p $name
cd $name
bsdtar xf ../"$filename"
tar xf data.tar.xz
cd usr/share
sudo rm -rf /usr/share/code
sudo cp -r code /usr/share/
sudo cp -r appdata/code.appdata.xml /usr/share/appdata
sudo cp -r applications/code*.desktop /usr/share/applications
sudo cp -r pixmaps/*.png /usr/share/pixmaps
sudo cp -r bash-completion/completions/code /usr/share/bash-completion/completions
sudo cp -r mime/packages/code-workspace.xml /usr/share/mime/packages/
sudo mkdir -p /usr/share/zsh/vendor-completions
sudo cp -r zsh/vendor-completions/_code /usr/share/zsh/vendor-completions
sudo ln -sf /usr/share/code/bin/code /usr/bin/
echo $version | sudo tee /var/lib/custom-packages/$name
cd ../../..
rm -rf $name $filename
