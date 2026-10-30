#!/bin/bash
set -e
name=jchempaint-git
_name=jchempaint
repo=JChemPaint/$_name
homepage="https://jchempaint.github.io/"
description="Skeletal structure drawing application."
version=$(gh_com $repo)
depends=(maven-bin)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
# The CLI opens files with a null panel, but getChemModelFromReader assumes
# that a panel exists. Guard this optional R-group reset so normal file opens
# work from file managers and command-line arguments.
python - <<'PY'
from pathlib import Path

needle = "panel.get2DHub().setRGroupHandler(null);"
sources = [
    path for path in Path(".").rglob("JChemPaint.java")
    if needle in path.read_text(encoding="utf-8")
]
if len(sources) != 1:
    raise SystemExit(
        f"Expected one JChemPaint.java with the null-panel bug; found {len(sources)}"
    )

source = sources[0]
text = source.read_text(encoding="utf-8")
source.write_text(
    text.replace(
        needle,
        "if (panel != null) panel.get2DHub().setRGroupHandler(null);",
        1,
    ),
    encoding="utf-8",
)
print(f"Patched null-panel file opening in {source}")
PY
PATH=$PATH:/opt/maven/bin LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/maven/lib mvn install -DskipTests
sudo mkdir -p /opt/jchempaint
sudo cp -r $(find . -name "JChemPaint.jar" -type f) /opt/jchempaint/jchempaint.jar
cat > /usr/bin/jchempaint << EOF
#!/bin/bash
export PATH=\$PATH:/opt/jdk/bin
exec java -jar /opt/jchempaint/jchempaint.jar "\$@"
EOF
sudo chmod +x /usr/bin/jchempaint
sudo tee /usr/share/applications/io.github.jchempaint.JChemPaint.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=JChemPaint
GenericName=Chemical 2D structure editor
Icon=io.github.jchempaint.JChemPaint
Exec=/usr/bin/jchempaint %F
TryExec=/usr/bin/jchempaint
MimeType=chemical/x-cml;chemical/x-daylight-smiles;text/plain;chemical/x-mdl-sdfile;chemical/x-mdl-molfile;chemical/x-mdl-rxnfile;
Categories=Science;Chemistry;Education;
StartupWMClass=org-openscience-jchempaint-application-JChemPaint
EOF
sudo cp -r appstream/io.github.jchempaint.JChemPaint.512.png /usr/share/pixmaps/io.github.jchempaint.JChemPaint.png
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
