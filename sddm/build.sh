#!/bin/bash
set -e
name=sddm
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm linux-pam llvm lm-sensors mesa mitkrb openssl pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
      -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D RUNTIME_DIR=/run/sddm            \
      -D BUILD_MAN_PAGES=ON               \
      -D BUILD_WITH_QT6=ON                \
      -D DATA_INSTALL_DIR=/usr/share/sddm \
      -D DBUS_CONFIG_FILENAME=sddm_org.freedesktop.DisplayManager.conf
)
cmaki "${options[@]}"
sudo tee /etc/pam.d/sddm > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/sddm
auth        requisite   pam_nologin.so
auth        required    pam_env.so
auth        required    pam_succeed_if.so uid >= 1000 quiet
auth        include     system-auth
-auth       optional    pam_gnome_keyring.so
-auth       optional    pam_kwallet5.so

account     include     system-account

password    include     system-password
-password   optional    pam_gnome_keyring.so use_authtok

session     required    pam_limits.so
#session     include     system-session
session include system-login
-session    optional    pam_gnome_keyring.so auto_start
-session    optional    pam_kwallet5.so auto_start
# End /etc/pam.d/sddm
PAMEOF
sudo tee /etc/pam.d/sddm-autologin > /dev/null << 'PAMEOF'
# Begin /etc/pam.d/sddm-autologin
auth        requisite   pam_nologin.so
auth        required    pam_env.so
auth        required    pam_succeed_if.so uid >= 1000 quiet
auth        required    pam_permit.so
-auth       optional    pam_gnome_keyring.so
-auth       optional    pam_kwallet5.so

account     include     system-account

password    required    pam_deny.so

session     required    pam_limits.so
#session     include     system-session
session include system-login
-session    optional    pam_gnome_keyring.so auto_start
-session    optional    pam_kwallet5.so auto_start
# End /etc/pam.d/sddm-autologin
PAMEOF

cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
