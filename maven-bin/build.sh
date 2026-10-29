#!/bin/bash
set -e
name=maven-bin
_name=maven
get_version() {
	local up_ver=$(wget -T 5 -t 1 -cqO- https://maven.apache.org/download.cgi | grep "\-bin.tar.gz" | head -n 1 | cut -d '/' -f 6)
	local inst_ver=$(pkgver $_name)
	local arch_ver=$(aver $_name)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	fver "$_name" "$inst_ver"
}
homepage="https://maven.apache.org/"
description="Java project management."
version=$(get_version)
filename="apache-$_name-$version-bin.tar.gz"
direname="apache-$_name-$version"
download_src "https://dlcdn.apache.org/maven/maven-$(echo $version | cut -d '.' -f 1)/$version/binaries/$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /opt/maven/
for i in bin lib boot conf
do
	sudo cp -r $i /opt/maven
done
sudo tee /etc/profile.d/maven.sh << EOF
#!/bin/bash
export PATH=\$PATH:/opt/maven/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/maven/lib
EOF
sudo chmod +x /etc/profile.d/maven.sh
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
