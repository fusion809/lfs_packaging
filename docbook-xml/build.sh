#!/bin/bash
set -e
name=docbook-xml
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://archive.docbook.org/xml/4.5/ | grep "docbook-xml-[0-9.]+" -oE | sed 's/docbook-xml-//g' | sed 's/\.$//g' | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.zip"
direname="${filename/.zip/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://archive.docbook.org/xml/$version/$filename
fi
rm -rf "$direname"
mkdir $direname
cd "$direname"
unzip ../$filename
sudo su -c "install -v -d -m755 /usr/share/xml/docbook/xml-dtd-$version &&
install -v -d -m755 /etc/xml                           &&
cp -v -af --no-preserve=ownership                      \
    catalog.xml docbook.cat *.dtd ent/ *.mod           \
    /usr/share/xml/docbook/xml-dtd-$version
xmlcatalog --noout --add \"rewriteSystem\"        \
    \"http://www.oasis-open.org/docbook/xml/$version\" \
    \"file:///usr/share/xml/docbook/xml-dtd-$version\" \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml &&

xmlcatalog --noout --add \"rewriteURI\"           \
    \"http://www.oasis-open.org/docbook/xml/$version\" \
    \"file:///usr/share/xml/docbook/xml-dtd-$version\" \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml
if [ ! -e /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi &&

xmlcatalog --noout --add \"delegatePublic\"                   \
    \"-//OASIS//ENTITIES DocBook XML\"                        \
    \"file:///usr/share/xml/docbook/xml-dtd-$version/catalog.xml\" \
    /etc/xml/catalog                                        &&

xmlcatalog --noout --add \"delegatePublic\"                   \
    \"-//OASIS//DTD DocBook XML\"                             \
    \"file:///usr/share/xml/docbook/xml-dtd-$version/catalog.xml\" \
    /etc/xml/catalog                                        &&

xmlcatalog --noout --add \"delegateSystem\"                   \
    \"http://www.oasis-open.org/docbook/\"                    \
    \"file:///usr/share/xml/docbook/xml-dtd-$version/catalog.xml\" \
    /etc/xml/catalog                                        &&

xmlcatalog --noout --add \"delegateURI\"                      \
    \"http://www.oasis-open.org/docbook/\"                    \
    \"file:///usr/share/xml/docbook/xml-dtd-$version/catalog.xml\" \
    /etc/xml/catalog
for DTDVERSION in 4.1.2 4.2 4.3 4.4
do
  xmlcatalog --noout --add \"public\"                                  \
    \"-//OASIS//DTD DocBook XML V$DTDVERSION//EN\"                     \
    \"http://www.oasis-open.org/docbook/xml/$DTDVERSION/docbookx.dtd\" \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml

  xmlcatalog --noout --add \"rewriteSystem\"              \
    \"http://www.oasis-open.org/docbook/xml/$DTDVERSION\" \
    \"file:///usr/share/xml/docbook/xml-dtd-$version\"         \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml
  
  xmlcatalog --noout --add \"rewriteURI\"                 \
    \"http://www.oasis-open.org/docbook/xml/$DTDVERSION\" \
    \"file:///usr/share/xml/docbook/xml-dtd-$version\"         \
    /usr/share/xml/docbook/xml-dtd-$version/catalog.xml
done"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
