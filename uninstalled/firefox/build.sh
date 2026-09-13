#!/bin/bash
set -e
name=firefox
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://archive.mozilla.org/pub/firefox/releases/ | grep "[0-9]+\.[0-9]+\.[0-9]+esr" -oE | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/mozilla-firefox/firefox.git | grep "esr_RELEASE" | sed 's/.*FIREFOX_//g' | sed 's/_RELEASE//g' | tr '_' '.' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
}
version=$(get_version)
depends=(alsa-lib at-spi2-core brotli bzip2 cairo dav1d dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu lcms2 libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libaom libepoxy libevent libffi libjpeg-turbo libpng libseccomp libvpx libwebp libxcb libxkbcommon nspr nss pango pcre2 pixman sqlite systemd util-linux wayland zlib)
filename="$name-$version.source.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://archive.mozilla.org/pub/firefox/releases/$version/source/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cat > mozconfig << "EOF"
# If you have a multicore machine, all cores will be used by default.

# If you have installed (or will install) wireless-tools, and you wish
# to use geolocation web services, comment out this line
ac_add_options --disable-necko-wifi

# Comment out the following line if you wish not to use Google's Location
# Service (GLS).  Note that if Geoclue is installed and configured to use
# GLS (as the BLFS instruction does), Firefox can access GLS via Geoclue
# anyway.  On the other hand if Geoclue is not installed (or not properly
# configured) and this line is commented out, the website requiring a
# location service will not function properly.
ac_add_options --with-google-location-service-api-keyfile=$PWD/google-key

# If you wish to use libproxy to determine proxy server information, you will
# need to install the libproxy package and then uncomment the option below:
#ac_add_options --enable-libproxy

# Uncomment the following option if you have not installed PulseAudio and
# want to use alsa instead
#ac_add_options --enable-audio-backends=alsa

# Comment out following options if you have not installed
# recommended dependencies:
ac_add_options --with-system-av1
ac_add_options --with-system-icu
ac_add_options --with-system-libevent
ac_add_options --with-system-libvpx
ac_add_options --with-system-nspr
ac_add_options --with-system-nss
ac_add_options --with-system-webp

# Firefox provides a copy of dav1d if it has not been installed. If you have
# not installed nasm and ffmpeg, uncomment the following line:
#ac_add_options --disable-av1

# You cannot distribute the binary if you do this.
ac_add_options --enable-official-branding

# Stripping is now enabled by default.
# Uncomment these lines if you need to run a debugger:
#ac_add_options --disable-strip
#ac_add_options --disable-install-strip

# Disabling debug symbols makes the build much smaller and a little
# faster. Comment this if you need to run a debugger.
ac_add_options --disable-debug-symbols

# The BLFS editors recommend not changing anything below this line:
ac_add_options --prefix=/usr
ac_add_options --enable-application=browser
ac_add_options --disable-crashreporter
ac_add_options --disable-updater

# Enabling the tests will use a lot more space and significantly
# increase the build time, for no obvious benefit.
ac_add_options --disable-tests

# This enables SIMD optimization in the shipped encoding_rs crate.
ac_add_options --enable-rust-simd

ac_add_options --enable-system-ffi
ac_add_options --enable-system-pixman

ac_add_options --with-system-jpeg
ac_add_options --with-system-png
ac_add_options --with-system-zlib

# Sandboxing works well on x86_64 but might cause issues on other
# platforms, e.g. i686.
[ $(uname -m) != x86_64 ] && ac_add_options --disable-sandbox

# Using sandboxed wasm libraries has been moved to all builds instead
# of only mozilla automation builds. It requires extra llvm packages
# and was reported to seriously slow the build. Disable it.
ac_add_options --without-wasm-sandboxed-libraries

# The following option unsets Telemetry Reporting. With the Addons Fiasco,
# Mozilla was found to be collecting user's data, including saved passwords and
# web form data, without users consent. Mozilla was also found shipping updates
# to systems without the user's knowledge or permission.
# As a result of this, use the following command to permanently disable
# telemetry reporting in Firefox.
unset MOZ_TELEMETRY_REPORTING

mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-build-dir

# By default firefox will attempt to use the window class firefox-default on
# launch. This makes the icon not work properly because wayland does not
# support the X11 property  class header. Change the remoting name to fix this.
# This is also reflected in the .desktop file where StartupWMClass is set to
# firefox.
MOZ_APP_REMOTINGNAME=firefox
EOF
gap_patches "$name"
key_comm=$(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/xsoft/firefox.html | grep "google-key" | sed -E 's/.*command">//g' | sed -E 's|</kbd.*||g' | sed 's/&gt;/>/g'  | tail -n 1)
"$key_comm"
export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none &&
export MOZBUILD_STATE_PATH=${PWD}/mozbuild          &&
./mach build
sudo su -c "export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none &&
./mach install"
unset MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE
unset MOZBUILD_STATE_PATH
sudo su -c 'mkdir -pv /usr/share/applications &&
mkdir -pv /usr/share/pixmaps      &&

MIMETYPE="text/xml;text/mml;text/html;"                            &&
MIMETYPE+="application/xhtml+xml;application/vnd.mozilla.xul+xml;" &&
MIMETYPE+="x-scheme-handler/http;x-scheme-handler/https"           &&

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

unset MIMETYPE &&

ln -sfv /usr/lib/firefox/browser/chrome/icons/default/default128.png \
        /usr/share/pixmaps/firefox.png'
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
