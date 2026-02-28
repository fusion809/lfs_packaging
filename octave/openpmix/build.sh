#!/bin/bash
set -e
_name=pmix
VERSION=$(wget -cqO- https://github.com/openpmix/openpmix/releases | grep "/releases/tag/v" | grep -v "rc" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | sed 's/^v//g')
filename="$_name-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/openpmix/openpmix/releases/download/v$VERSION/$filename
fi
tar xf $filename
cd ${filename/.tar.gz/}
./autogen.pl
local configure_options=(
    --prefix=/usr
    --sysconfdir=/etc/$NAME
  )

# set environment variables for reproducible build
# see https://docs.openpmix.org/en/latest/release-notes/general.html
export HOSTNAME=buildhost
export USER=builduser

./configure "${configure_options[@]}"
# prevent excessive overlinking due to libtool
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
make V=1 -j$(nproc)
sudo make install
cd ..
rm -rf $filename ${filename/.tar.gz/}
