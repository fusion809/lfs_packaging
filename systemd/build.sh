#!/bin/bash
set -e
name=systemd
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
function lfs_ver {
	# Some local package names differ from LFS/BLFS tarball names — map them here.
	# fallback_page: relative path to the individual BLFS page for packages whose
	# version doesn't appear in the index pages (e.g. listed by display name, not tarball).
	local search_name fallback_page
	case "$1" in
		mitkrb) search_name="krb5"; fallback_page="postlfs/mitkrb.html" ;;
		vte) search_name="vte" ; fallback_page="gnome/vte.html";;
		*)       search_name="$1";  fallback_page="" ;;
	esac

	# Try the index pages first.
	local ver
	ver=$(wget --timeout=5 -t 1 -cqO- \
		https://www.linuxfromscratch.org/{b,}lfs/view/systemd/index.html \
		https://www.linuxfromscratch.org/blfs/view/systemd/longindex.html \
		https://www.linuxfromscratch.org/slfs/view/stable/ \
		| grep -iE ">$search_name-[0-9.]+" \
		| grep -vE "vte-2\.[0-9]+" \
		| sed -E "s/.*$search_name-([0-9.]+).*/\1/I" \
		| grep -E "^[0-9.]+$" | sort -V | tail -n 1)

	# If not found and a fallback page is defined, scrape the individual BLFS page.
	if [[ -z "$ver" && -n "$fallback_page" ]]; then
		ver=$(wget --timeout=5 -t 1 -cqO- \
			"https://www.linuxfromscratch.org/blfs/view/systemd/$fallback_page" \
			| grep -iE "$search_name-[0-9]+\.[0-9]" \
			| sed -E "s/.*$search_name-([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/I" \
			| grep -E "^[0-9.]+$" | sort -V | tail -n 1)
	fi
	echo "$ver"
}
_version=$(lfs_ver $name)
_filename="$name-man-pages-$_version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl bash coreutils dbus glibc gzip hwdata kbd kmod lz4 meson ninja openssl pcre2 tar util-linux wget xz)

if ! [[ -f $filename ]]; then
    wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
if ! [[ -f $_filename ]]; then
    wget -c --progress=bar:force https://anduin.linuxfromscratch.org/LFS/$_filename
fi
unpk_enter "$filename" "$direname"
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in
meson_options=(
    --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/$direname
)
mni "${meson_options[@]}"
sudo tar -xf ../../$_filename \
    --no-same-owner --strip-components=1 \
    -C /usr/share/man
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
echo "$_version" | sudo tee -a /var/lib/custom-packages/$name
