#!/bin/bash
set -e
name=elmerfem-git
_name=elmerfem
repo=elmercsc/$_name
homepage="https://www.elmerfem.org"
description="Finite element method solver for partial differential equations."
version=$(gh_com $repo)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(mumps openmpi netcdf-fortran cli11 qwt)
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
python3 - <<'PY'
from pathlib import Path

path = Path("cmake/Modules/FindMumps.cmake")
text = path.read_text()

old = "      LIST(APPEND Mumps_LIBRARIES ${SCALAPACK_LIBRARIES})"
new = """      LIST(APPEND Mumps_LIBRARIES ${SCALAPACK_LIBRARIES})

      # MUMPS was built with Scotch ordering support.
      FIND_LIBRARY(MUMPS_ESMUMPS_LIB NAMES esmumps)
      FIND_LIBRARY(MUMPS_SCOTCH_LIB NAMES scotch)
      FIND_LIBRARY(MUMPS_SCOTCHERR_LIB NAMES scotcherr)

      IF(NOT MUMPS_ESMUMPS_LIB OR NOT MUMPS_SCOTCH_LIB OR
         NOT MUMPS_SCOTCHERR_LIB)
        SET(MUMPS_FAILMSG "Scotch libraries required by MUMPS were not found.")
      ELSE()
        LIST(APPEND Mumps_LIBRARIES
          ${MUMPS_ESMUMPS_LIB}
          ${MUMPS_SCOTCH_LIB}
          ${MUMPS_SCOTCHERR_LIB})
      ENDIF()"""

if text.count(old) != 1:
    raise SystemExit(
        f"Expected exactly one insertion point; found {text.count(old)}. "
        "No changes made."
    )

path.write_text(text.replace(old, new, 1))
print(f"Updated {path}")
PY
cmaki -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DWITH_OpenMP:BOOLEAN=TRUE -DWITH_MPI:BOOLEAN=TRUE -DWITH_ElmerIce:BOOLEAN=TRUE -DWITH_Mumps:BOOL=TRUE -DWITH_ELMERGUI=TRUE -DWITH_QT6=TRUE -DCMAKE_PREFIX_PATH=$CMAKE_PREFIX_PATH:/usr/lib/netCDF
cd ..
sudo install -Dm644 ElmerGUI/Application/images/logo.png /usr/share/pixmaps/elmerfem.png
sudo tee /usr/share/applications/elmerfem.desktop << EOF
[Desktop Entry]
Type=Application
Exec=ElmerGUI
#MimeType=
Comment=A finite element software for multiphysical problems
Icon=elmerfem
Terminal=false
Name=ElmerGUI
Categories=Science;Physics;
StartupWMClass=ElmerGUI
EOF
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
