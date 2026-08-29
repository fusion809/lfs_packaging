#!/bin/bash
set -e
name=ninja
repo=${name}-build/$name
version=$(gh_ver $repo)
lfs_depends=(bash python gzip sed tar coreutils)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
export NINJAJOBS=3
sed -i '/int Guess/a \
  int   j = 0;\
  char* jobs = getenv( "NINJAJOBS" );\
  if ( jobs != NULL ) j = atoi( jobs );\
  if ( j > 0 ) return j;\
' src/ninja.cc
python3 configure.py --bootstrap --verbose
sudo su -c "install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja"
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
