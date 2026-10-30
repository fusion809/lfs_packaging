#!/bin/bash
set -e
name=accountsservice
homepage="https://freedesktop.org/wiki/Software/AccountsService/"
description="D-Bus interface for user account query and manipulation."
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
# AccountsService lists /run/systemd/seats as a read-only sandbox path. That
# directory is created by systemd-logind, so starting AccountsService before
# logind is ready makes systemd fail the unit during namespace setup. The
# service can then start later via D-Bus activation, which hides the boot race.
sudo install -d -m755 /usr/lib/systemd/system/accounts-daemon.service.d
sudo tee /usr/lib/systemd/system/accounts-daemon.service.d/logind.conf >/dev/null <<'EOF'
[Unit]
After=systemd-logind.service
EOF
sudo su -c "cat > /etc/polkit-1/rules.d/40-adm.rules << "EOF"
polkit.addAdminRule(function(action, subject) {
   return [\"unix-group:adm\"];
   });
EOF"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
