#!/bin/bash
set -e
name=linux-pam
version=$(curl -s https://api.github.com/repos/linux-pam/linux-pam/releases/latest | grep -oP '"tag_name":\s*"v\K[0-9.]+')
dirname="Linux-PAM-$version"
filename="$dirname.tar.xz"
depends=()
lfs_depends=(libxcrypt)
blfs_depends=()

if ! [ -f "$filename" ]; then
    wget -c "https://github.com/linux-pam/linux-pam/releases/download/v$version/$filename"
fi
rm -rf "$dirname"
tar xf "$filename"
cd "$dirname"

sed -e "s/'elinks'/'lynx'/"                       \
    -e "s/'-no-numbering', '-no-references'/      \
          '-force-html', '-nonumbers', '-stdin'/" \
    -i meson.build
mkdir build
cd build
meson setup ..        \
  --prefix=/usr       \
  --buildtype=release \
  -D docdir=/usr/share/doc/$dirname
ninja -j$(nproc)
sudo ninja install
sudo chmod -v 4755 /usr/sbin/unix_chkpwd

# Create PAM configuration files (must use proper heredocs, NOT inline)
sudo install -vdm755 /etc/pam.d

sudo tee /etc/pam.d/system-account > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/system-account
account   required    pam_unix.so
# End /etc/pam.d/system-account
PAMEOF

sudo tee /etc/pam.d/system-auth > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/system-auth
auth      required    pam_unix.so
# End /etc/pam.d/system-auth
PAMEOF

sudo tee /etc/pam.d/system-session > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/system-session
session   required    pam_unix.so
# End /etc/pam.d/system-session
PAMEOF

sudo tee /etc/pam.d/system-password > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/system-password
password  required    pam_unix.so yescrypt shadow try_first_pass
# End /etc/pam.d/system-password
PAMEOF

sudo tee /etc/pam.d/other > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/other
auth      required    pam_warn.so
auth      required    pam_deny.so
account   required    pam_warn.so
account   required    pam_deny.so
password  required    pam_warn.so
password  required    pam_deny.so
session   required    pam_warn.so
session   required    pam_deny.so
# End /etc/pam.d/other
PAMEOF

# Record package metadata
export CP="/var/lib/custom-packages"
echo "$version" > "$CP/$name"
sudo chmod 777 "$CP/$name"
rm -rf $dirname $filename
