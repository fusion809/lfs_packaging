#!/bin/bash
set -e
name=hub
repo=mislav/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
export CGO_CPPFLAGS="${CPPFLAGS}"
export CGO_CFLAGS="${CFLAGS}"
export CGO_CXXFLAGS="${CXXFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"
export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"
maki prefix=/usr
sudo su -c "install -Dm644 etc/hub.bash_completion.sh /usr/share/bash-completion/completions/hub
  install -Dm644 etc/hub.zsh_completion /usr/share/zsh/site-functions/_hub
  install -Dm644 etc/hub.fish_completion /usr/share/fish/vendor_completions.d/hub.fish"
cd ..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
