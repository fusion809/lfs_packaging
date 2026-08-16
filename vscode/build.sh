#!/bin/bash
name=vscode
version=$(git ls-remote --tags https://github.com/microsoft/vscode.git | grep -oP 'refs/tags/\K[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -n 1)
depends=(elfutils glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libxkbfile mesa mitkrb openldap orc pango pcre2 wayland)
blfs_depends=(alsa-lib at-spi2-core avahi brotli cairo cups curl cyrus-sasl dav1d enchant fontconfig freetype fribidi gdk-pixbuf glycin graphite2 gst-plugins-base gstreamer harfbuzz highway keyutils lcms2 libXau libXdmcp libaom libavif libdrm libepoxy libgcrypt libgpg-error libidn2 libjpeg-turbo libjxl libpng libpsl libseccomp libsecret libsoup libtasn1 libunistring libunwind libwebp libxcb libxkbcommon libxml2 libxslt nghttp2 nspr nss pixman svt-av1 webkitgtk)
lfs_depends=(bzip2 dbus e2fsprogs expat gcc glibc libelf libffi libxcrypt openssl sqlite systemd util-linux xz zlib zstd)
filename="code_${version}_amd64.deb"
if ! [[ -f $filename ]]; then
	wget -c https://update.code.visualstudio.com/${version}/linux-deb-x64/stable -O "$filename"
fi

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
echo $version > /var/lib/custom-packages/$name
cd ../../..
rm -rf $name $filename
