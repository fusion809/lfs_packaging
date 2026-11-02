#!/bin/bash
set -e
name=pinta
_name=Pinta
repo=PintaProject/$_name
homepage="http://www.pinta-project.com/"
description="Simple GTK .NET paint program."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(autoconf-archive dotnet-bin)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt TargetFramework=net10.0 AllowMissingPrunePackageData=true dotnet restore Pinta/Pinta.csproj
sed -i 's|"/icons"|"/pinta/icons"|' Pinta/Main.cs
sed -i 's|^DOTNET_TARGET_FRAMEWORK=.*$|DOTNET_TARGET_FRAMEWORK="net10.0"|' configure.ac
sed -i 's|^DOTNET_CMD=.*$|DOTNET_CMD="env SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt AllowMissingPrunePackageData=true TargetFramework=$DOTNET_TARGET_FRAMEWORK $DOTNET"|' configure.ac
sudo autoreconf -fiv
sudo chown $USER -R .
cmi --prefix=/usr --sysconfdir=/etc --localstatedir=/var
sudo su -c "install -dm755 /usr/share/pinta/icons/hicolor/{16x16,scalable}
mv /usr/share/{,pinta/}icons/hicolor/16x16/actions
mv /usr/share/{,pinta/}icons/hicolor/scalable/actions"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
