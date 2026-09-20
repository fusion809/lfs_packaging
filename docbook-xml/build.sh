#!/bin/bash
set -e
name=docbook-xml
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.docbook.org/xml/4.5/ | grep "docbook-xml-[0-9.]+" -oE | sed 's/docbook-xml-//g' | sed 's/\.$//g' | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.zip"
direname="${filename/.zip/}"
download_src "https://archive.docbook.org/xml/$version/$filename"
mkdir $direname
cd $direname
unzip ../$filename
sudo su -c "
install -v -d -m755 /usr/share/xml/docbook/xml-dtd-$version &&
install -v -d -m755 /etc/xml &&
cp -v -af --no-preserve=ownership \
    catalog.xml docbook.cat *.dtd ent/ *.mod \
    /usr/share/xml/docbook/xml-dtd-$version
xmlcatalog --noout --del \
    'http://www.oasis-open.org/docbook/xml/' \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml

xmlcatalog --noout --del \
    'http://www.oasis-open.org/docbook/xml/' \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml

for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
    xmlcatalog --noout --add \"public\" \
        \"-//OASIS//DTD DocBook XML V$DTDVERSION//EN\" \
        \"file:///usr/share/xml/docbook/xml-dtd-$version/docbookx.dtd\" \
        /usr/share/xml/docbook/xml-dtd-$version/catalog.xml

    xmlcatalog --noout --add \"system\" \
        \"http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd\" \
        \"file:///usr/share/xml/docbook/xml-dtd-$version/docbookx.dtd\" \
        /usr/share/xml/docbook/xml-dtd-$version/catalog.xml

    xmlcatalog --noout --add \"uri\" \
        \"http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd\" \
        \"file:///usr/share/xml/docbook/xml-dtd-$version/docbookx.dtd\" \
        /usr/share/xml/docbook/xml-dtd-$version/catalog.xml
done
"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"

