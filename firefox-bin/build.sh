#!/bin/bash
set -e
name=firefox-bin
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- https://ftp.mozilla.org/pub/firefox/releases/ | grep "[0-9]+\.[0-9]+\.[0-9b]+" -oE | grep -v "b" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(alsa-lib at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libepoxy libffi libpng libseccomp libxcb libxkbcommon nspr nss pango pcre2 pixman systemd util-linux wayland zlib)
filename="firefox-$version.tar.xz"
direname="firefox"
if ! [[ -f $filename ]]; then
	wget -c https://ftp.mozilla.org/pub/firefox/releases/$version/linux-x86_64/en-GB/$filename
fi
rm -rf "$direname"
tar xf "$filename"
sudo mkdir -p /usr/lib/firefox
sudo cp -r $direname/* /usr/lib/firefox
sudo cp -r $direname/browser/chrome/icons/default/default128.png /usr/share/pixmaps/firefox.png
cat > /usr/share/applications/firefox.desktop << EOF &&
[Desktop Entry]
Encoding=UTF-8
Name=Firefox Web Browser
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=firefox %u
Terminal=false
Type=Application
Icon=firefox
Categories=GNOME;GTK;Network;WebBrowser;
MimeType=$MIMETYPE
StartupNotify=true
StartupWMClass=firefox
EOF
sudo ln -sf /usr/lib/firefox/firefox /usr/bin/
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
