#!/bin/bash
set -e
name=meson
repo=${name}build/$name
version=$(gh_ver $repo)
depends=(bash coreutils gzip ninja python tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
pip3 wheel -w dist --no-cache-dir --no-build-isolation --no-deps $PWD
sudo su -c "pip3 install --no-index --find-links dist meson
install -vDm644 data/shell-completions/bash/meson /usr/share/bash-completion/completions/meson
install -vDm644 data/shell-completions/zsh/_meson /usr/share/zsh/site-functions/_meson"
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
