#!/bin/bash
set -e
name=postgresql
_name=postgres
repo=$_name/$_name
homepage="https://www.postgresql.org/"
description="Advanced object-relational database management system."
version=$(gh_ver $repo $name)
depends=(gcc icu ncurses readline ssw zlib)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "https://ftp.postgresql.org/pub/source/v$version/$filename"
unpk_enter "$filename" "$direname"
sed -e '/DEFAULT_PGSOCKET_DIR/s@/tmp@/run/postgresql@' \
    -i src/include/pg_config_manual.h
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
sudo su -c "install -v -dm700 /srv/pgsql/data &&
install -v -dm755 /run/postgresql &&
chown -Rv postgres:postgres /srv/pgsql /run/postgresql"
sudo su - postgres -c '/usr/bin/initdb -D /srv/pgsql/data'
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
