#!/bin/bash
set -e
# Variable declaration
name=java
majorver=$(curl -s https://jdk.java.net/ | grep "Early access:" | cut -d '/' -f 2)
minorver=$(curl -s https://jdk.java.net/$majorver/ | grep ">Build" | cut -d ' ' -f 2)
version="$majorver+$minorver"
filename="openjdk-$majorver-ea+${minorver}_linux-x64_bin.tar.gz"
direname="jdk-$majorver"
instdir="jdk-$version"
blfs_depends=(alsa-lib
	cups
	giflib
	lcms
	x7lib)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.java.net/java/early_access/jdk$majorver/$minorver/GPL/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
sudo rm -rf /opt/jdk-*
sudo mv $direname /opt/$instdir
sudo ln -sf /opt/$instdir /opt/jdk
sudo chown root:root -R /opt/$instdir
rm -rf $filename
echo $version > /var/lib/custom-packages/$name
