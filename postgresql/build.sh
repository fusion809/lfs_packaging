#!/bin/bash
set -e
name=postgresql
_name=postgres
repo=$_name/$_name
homepage="https://www.postgresql.org/"
description="Advanced object-relational database management system."
version=$(gh_ver $repo $name)
_version=$(echo $version | sed -E 's/\./_/g')
depends=(gcc icu ncurses readline ssw zlib)
filename="$_name-REL_$_version.tar.gz"
direname="${filename/.tar.*/}"
#download_src "https://ftp.postgresql.org/pub/source/v$version/$filename"
gha_download "$repo" "REL_${_version}" "$filename"
unpk_enter "$filename" "$direname"
sed -e '/DEFAULT_PGSOCKET_DIR/s@/tmp@/run/postgresql@' \
    -i src/include/pg_config_manual.h
sed -i '/#include "exprparse.h"/a typedef YY_BUFFER_STATE yybuffer;' \
    src/bin/pgbench/exprscan.l
cmi --prefix=/usr --docdir=/usr/share/doc/$direname
sudo su -c "
if ! [[ -d /srv/pgsql/data ]]; then
	install -v -dm700 /srv/pgsql/data
	install -v -dm755 /run/postgresql
	chown -Rv postgres:postgres /srv/pgsql /run/postgresql
	su - postgres -c '/usr/bin/initdb -D /srv/pgsql/data'
fi"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
