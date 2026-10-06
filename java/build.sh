#!/bin/bash
set -e
# Variable declaration
name=java
homepage="https://www.java.com/"
description="OpenJDK Java development kit - development branch."
majorver=$(curl -s https://jdk.java.net/ | grep "Early access:" | cut -d '/' -f 2)
minorver=$(curl -s https://jdk.java.net/$majorver/ | grep ">Build" | cut -d ' ' -f 2)
version="$majorver+$minorver"
filename="openjdk-$majorver-ea+${minorver}_linux-x64_bin.tar.gz"
direname="jdk-$majorver"
instdir="jdk-$version"
depends=(alsa-lib brotli bzip2 cups freetype giflib glibc lcms libpng libx11 libxau libxcb libxdmcp libxext libxi libxrender libxtst x7lib zlib)
# Fetch source and unpack
download_src "https://download.java.net/java/early_access/jdk$majorver/$minorver/GPL/$filename"
rm -rf $direname
tar xf $filename
# Compile and install
sudo rm -rf /opt/jdk-*
sudo mv $direname /opt/$instdir
sudo ln -sf /opt/$instdir /opt/jdk
sudo chown root:root -R /opt/$instdir
rm -rf $filename
echo $version | sudo tee /var/lib/custom-packages/$name
