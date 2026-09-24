#!/bin/bash
set -e
name=linux-pam
repo=linux-pam/linux-pam
version=$(gh_ver "$repo")
if [[ -z ${version// /} ]]; then
	echo "Version is empty."
	exit 1
fi
direname="Linux-PAM-$version"
filename="$direname.tar.xz"
depends=(gcc gdbm glibc libselinux libxcrypt pcre2 systemd)

ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"

sed -e "s/'elinks'/'lynx'/"                       \
    -e "s/'-no-numbering', '-no-references'/      \
          '-force-html', '-nonumbers', '-stdin'/" \
    -i meson.build
meson_options=(
  --prefix=/usr       \
  --buildtype=release \
  -D docdir=/usr/share/doc/$direname \
  -D selinux=enabled
)
mni "${meson_options[@]}"
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

sudo tee /etc/pam.d/su > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/su
auth      sufficient  pam_rootok.so
auth      include     system-auth
account   include     system-account
session   required    pam_env.so
session   include     system-session
# End /etc/pam.d/su
PAMEOF
# Record package metadata
export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name"
rm -rf $direname $filename
