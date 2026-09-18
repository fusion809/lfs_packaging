#!/bin/bash
set -e
name=accountsservice
repo=$name/$name
version=$(gfd_ver $repo)
depends=(glib2 glibc json-c libffi libxcrypt pcre2 polkit systemd util-linux zlib)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
   --prefix=/usr \
   --buildtype=release \
   -D admin_group=adm
)
mni "${meson_options[@]}"
sudo su -c "cat > /etc/polkit-1/rules.d/40-adm.rules << "EOF"
polkit.addAdminRule(function(action, subject) {
   return [\"unix-group:adm\"];
   });
EOF"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
