#!/bin/bash
set -e
name=git
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli curl cyrus-sasl expat glibc libidn2 libpsl libunistring nghttp2 openldap openssl pcre2 zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.kernel.org/pub/software/scm/git/$filename
fi
man_filename="$name-manpages-$version.tar.xz"
if ! [[ -f $man_filename ]]; then
	wget -c --progress=bar:force https://www.kernel.org/pub/software/scm/git/$man_filename
fi
html_filename="$name-htmldocs-$version.tar.xz"
if ! [[ -f $html_filename ]]; then
	wget -c --progress=bar:force https://www.kernel.org/pub/software/scm/git/$html_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --with-gitconfig=/etc/gitconfig --with-python=python3 --with-libpcre2
make -j$(nproc)
perl_version=$(pkgver perl)
perl_majVer=$(echo $perl_version | sed -E 's/\.[0-9]+$//g')
sudo make perllibdir=/usr/lib/perl5/$perl_majVer/site_perl install
sudo tar -xf ../$man_filename \
    -C /usr/share/man --no-same-owner --no-overwrite-dir
sudo su -c "mkdir -vp   /usr/share/doc/$direname &&
tar   -xf   ../$html_filename \
      -C    /usr/share/doc/$direname --no-same-owner --no-overwrite-dir &&

find        /usr/share/doc/$direname -type d -exec chmod 755 {} \; &&
find        /usr/share/doc/$direname -type f -exec chmod 644 {} \;"
sudo su -c "mkdir -vp /usr/share/doc/$direname/man-pages/{html,text}         &&
mv        /usr/share/doc/$direname/{git*.adoc,man-pages/text}    &&
mv        /usr/share/doc/$direname/{git*.,index.,man-pages/}html &&

mkdir -vp /usr/share/doc/$direname/technical/{html,text}         &&
mv        /usr/share/doc/$direname/technical/{*.adoc,text}       &&
mv        /usr/share/doc/$direname/technical/{*.,}html           &&

mkdir -vp /usr/share/doc/$direname/howto/{html,text}             &&
mv        /usr/share/doc/$direname/howto/{*.adoc,text}           &&
mv        /usr/share/doc/$direname/howto/{*.,}html               &&

sed -i '/^<a href=/s|howto/|&html/|' /usr/share/doc/$direname/howto-index.html &&
sed -i '/^\* link:/s|howto/|&html/|' /usr/share/doc/$direname/howto-index.adoc"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
