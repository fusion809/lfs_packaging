#!/bin/bash
set -e
name=thunderbird-bin
_name=thunderbird
get_version() {
	local up_ver=$(wget -cqO- -T 5 -t 1 https://github.com/thunderbird/thunderbird-desktop/tags | grep "RELEASE.tar.gz" | grep -v "[0-9]b[0-9]" | grep -oE "[0-9]+_[0-9]" | tr '_' '.' | sort -V | tail -n 1)
	local inst_ver=$(pkgver $_name)
	local mon_ver=$(uver $_name)
	ver_check "$up_ver" "$inst_ver" "$mon_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://www.thunderbird.net/en-GB/"
description="Stand-alone mail/news client from Mozilla."
version=$(get_version)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://archive.mozilla.org/pub/thunderbird/releases/$version/linux-x86_64/en-GB/$filename"
unpk_enter "$filename"
sudo mkdir -p /usr/lib/$_name
sudo cp -r * /usr/lib/$_name
sudo cp -r chrome/icons/default/default128.png /usr/share/pixmaps/$_name.png
cat > /usr/share/applications/$_name.desktop << EOF &&
[Desktop Entry]
Encoding=UTF-8
Name=Thunderbird mail/news client
Comment=Check your email
GenericName=Email client
Exec=thunderbird %u
Terminal=false
Type=Application
Icon=thunderbird
Categories=GNOME;GTK;Network;Mail;MailClient;
MimeType=x-scheme-handler/mailto;application/x-xpinstall;
StartupNotify=true
StartupWMClass=thunderbird
EOF
sudo ln -sf /usr/lib/$_name/$_name /usr/bin/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
