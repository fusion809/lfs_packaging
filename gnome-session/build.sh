#!/bin/bash
set -e
name=gnome-session
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype gcc gdk-pixbuf glib2 glibc glycin gnome-desktop icu lcms2 libffi libpng libseccomp libxkbcommon libxml2 pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr 
    --buildtype=release 
    -D man=false 
    -D docbook=false
)
mni "${options[@]}"
cat >> gnome-session-sddm-wrapper << EOF
#!/bin/bash
systemctl --user stop graphical-session.target graphical-session-pre.target 2>/dev/null || true
systemctl --user reset-failed 2>/dev/null || true
exec /usr/bin/gnome-session "\$@"
EOF
sudo sed -i -e "s|/usr/bin/gnome-session|/usr/bin/gnome-session-sddm-wrapper|g" /usr/share/wayland-sessions/gnome.desktop
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
