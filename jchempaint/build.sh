#!/bin/bash
set -e
name=jchempaint
repo=JChemPaint/$name
homepage="https://jchempaint.github.io/"
description="Skeletal structure drawing application."
version=$(gh_com $repo)
depends=(maven-bin)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
PATH=$PATH:/opt/maven/bin LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/maven/lib mvn install -DskipTests
sudo mkdir -p /opt/jchempaint
sudo cp -r $(find . -name "JChemPaint.jar" -type f) /opt/jchempaint/jchempaint.jar
cat > /usr/bin/jchempaint << EOF
#!/bin/bash
exec java -jar /opt/jchempaint/jchempaint.jar "\$@"
EOF
sudo chmod +x /usr/bin/jchempaint
sudo cp -r appstream/io.github.jchempaint.JChemPaint.desktop /usr/share/applications
sudo cp -r appstream/io.github.jchempaint.JChemPaint.512.png /usr/share/pixmaps/io.github.jchempaint.JChemPaint.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
