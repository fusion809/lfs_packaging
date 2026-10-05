#!/bin/bash
set -e
name=sagemath
_name=sage
repo=$name/$_name
homepage="https://www.sagemath.org/"
description="Open-source mathematics software system integrating multiple others."
version=$(gh_ver $repo)
depends=(R blas-lapack bzip2 gcc glibc glpk gmp icu libffi libtirpc mpc mpfr ncurses openblas pcre2 readline suitesparse xz zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://mirror.aarnet.edu.au/pub/sage/src/$filename"
unpk_enter "$filename" "$direname"
sudo rm -rf /opt/sage-*
sudo mkdir -p /opt/$direname
if ! [[ -d /home/builder ]]; then
	sudo useradd -m builder
fi
sudo chown builder /opt/$direname . -R
sudo -u builder -H bash -c "
./configure --prefix=/opt/$direname --with-sage-venv=yes --disable-editable
make -j$(nproc)
"
sudo make install
cat > /etc/profile.d/sagemath.sh << EOF
export SAGE_ROOT=/opt/sage-10.10
pathappend $SAGE_ROOT/bin
pathappend $SAGE_ROOT/lib LD_LIBRARY_PATH
EOF
sudo chmod +x /etc/profile.d/sagemath.sh
sudo chown root:root -R /opt/$direname
#cd ..
#sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
