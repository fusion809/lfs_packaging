#!/bin/bash
set -e
name=tzdata
_timezones=('africa' 'antarctica' 'asia' 'australasia'
           'europe' 'northamerica' 'southamerica'
           'etcetera' 'backward' 'factory')
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 2 -t 1 -cqO- https://www.iana.org/time-zones | grep "time-zones/releases" | cut -d '/' -f 4 | sed 's/".*//g' | head -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="tzdata${version}.tar.gz"
direname="tzdata${version}"
if ! [[ -f $filename ]]; then
	wget -c https://www.iana.org/time-zones/repository/releases/$filename
fi
rm -rf $direname
mkdir $direname
tar xf $filename -C $direname
cd $direname
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica \
 asia australasia backward; do
 sudo zic -L /dev/null -d $ZONEINFO ${tz}
 sudo zic -L /dev/null -d $ZONEINFO/posix ${tz}
 sudo zic -L leapseconds -d $ZONEINFO/right ${tz}
done
sudo cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
sudo zic -d $ZONEINFO -p America/New_York
unset ZONEINFO tz
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name

