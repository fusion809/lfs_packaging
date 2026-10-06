#!/bin/bash
set -e
name=sagemath
_name=sage
repo=$name/$_name
homepage="https://www.sagemath.org/"
description="Open-source mathematics software system integrating multiple others."
version=$(gh_ver $repo)
depends=(blas-lapack brotli bzip2 cmake dav1d freetype gcc glibc glpk gmp icu lcms2 libaom libavif libffi libjpeg-turbo libpng libtirpc libunwind libwebp libxau libxcb libxdmcp libyaml make mpc mpfr ncurses openblas openjpeg pcre2 python qhull r readline suitesparse svt-av1 tiff xz zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://mirror.aarnet.edu.au/pub/sage/src/$filename"
unpk_enter "$filename" "$direname"
oldver=$(pkgver $name)
sudo rm -rf /opt/$direname
sudo mkdir -p /opt/$direname

if ! [[ -d /home/builder ]]; then
	sudo useradd -m builder
fi

sudo chown -R builder /opt/$direname .
sudo systemctl restart ntpd
sudo -u builder -H bash -c "
./configure --prefix=/opt/$direname --with-sage-venv=yes --disable-editable
until make -j$(nproc); do
    sudo systemctl restart ntpd
    export SAGE_KEEP_BUILD_SPKGS=yes
done
"
sudo ln -sf /opt/$direname /opt/sage
if [[ "$version" != "$oldver" ]] &&
   [[ "$(printf '%s\n' "$version" "$oldver" | sort -V | tail -n1)" == "$version" ]]; then
    sudo rm -rf /opt/sage-$oldver
fi

if ! [[ -f /usr/share/pixmaps/sagemath.png ]]; then
    sudo wget -c https://pbs.twimg.com/profile_images/464486563427004417/CoAviUnx_400x400.png -O /usr/share/pixmaps/sagemath.png
fi

if ! [[ -f /usr/share/icons/hicolor/512x512/apps/sagemath.png ]]; then
    sudo cp /usr/share/pixmaps/sagemath.png /usr/share/icons/hicolor/512x512/apps/sagemath.png
fi

# Find python version dynamically from venv directory
venv_dir=$(find /opt/sage/var/lib/sage -maxdepth 1 -type d -name "venv-python*" | head -n 1)

# Symlink sage binary into /opt/$direname/bin
sudo ln -sf "$venv_dir/bin/sage" /opt/$direname/bin/sage

# Environment setup
sudo tee /etc/profile.d/sagemath.sh << EOF
export SAGE_ROOT=/opt/sage
export VENV_ROOT=\$(ls \$SAGE_ROOT/var/lib/sage/venv-python* -ld | rev \
| cut -d ' ' -f 1 | rev)
pathappend \$SAGE_ROOT/bin:\$VENV_ROOT/bin
pathappend \$SAGE_ROOT/lib:\$VENV_ROOT/lib LD_LIBRARY_PATH
EOF
sudo chmod +x /etc/profile.d/sagemath.sh

sudo tee /usr/bin/sage << EOF
#!/bin/bash
export SAGE_ROOT=/opt/sage
export VENV_ROOT=\$(ls \$SAGE_ROOT/var/lib/sage/venv-python* -ld | rev \
	| cut -d ' ' -f 1 | rev)
export PATH=\$PATH:\$SAGE_ROOT/bin:\$VENV_ROOT/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$SAGE_ROOT/lib:\$VENV_ROOT/lib
$SAGE_ROOT/bin/sage "$@"
EOF
sudo chmod +x /usr/bin/sage
sudo tee /usr/share/applications/sage.desktop << EOF
[Desktop Entry]
Name=SageMath
Exec=gnome-terminal -- /usr/bin/sage
Type=Application
Icon=sagemath
Categories=Development;Education;Math;Science;
EOF

sudo tee /usr/bin/sage-jupyterlab << EOF
#!/bin/bash
export SAGE_ROOT=/opt/sage
export VENV_ROOT=\$(ls \$SAGE_ROOT/var/lib/sage/venv-python* -ld | rev \
	| cut -d ' ' -f 1 | rev)
export PATH=\$PATH:\$SAGE_ROOT/bin:\$VENV_ROOT/bin
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:\$SAGE_ROOT/lib:\$VENV_ROOT/lib
$SAGE_ROOT/bin/sage -n jupyterlab
EOF
sudo chmod +x /usr/bin/sage-jupyterlab

sudo tee /usr/share/applications/sage-jupyterlab.desktop << EOF
[Desktop Entry]
Name=SageMath JupyterLab
Exec=gnome-terminal -- /usr/bin/sage-jupyterlab
Type=Application
Icon=jupyterlab
Categories=Development;Education;Math;Science;
EOF

sudo chown -R root:root /opt/$direname

# Clean up source tree
cd ..
sudo rm -rf "$filename" "$direname"

echo "$version" | sudo tee "/var/lib/custom-packages/$name"
