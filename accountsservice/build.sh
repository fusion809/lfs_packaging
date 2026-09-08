#!/bin/bash
set -e
name=accountsservice
repo=$name/$name
version=$(gfd_ver $repo)
depends=(glib2 glibc json-c libffi libxcrypt pcre2 polkit systemd util-linux zlib)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/accountsservice/accountsservice/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr                   --buildtype=release 	    -D admin_group=adm)
mni "${meson_options[@]}"
sudo su -c "cat > /etc/polkit-1/rules.d/40-adm.rules << "EOF"
polkit.addAdminRule(function(action, subject) {
   return [\"unix-group:adm\"];
   });
EOF"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
