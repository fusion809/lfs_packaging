#!/bin/bash
set -e
name=cadcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Autodesk AutoCAD."
homepage="https://getartcraft.com/apps/cadcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
conflicts=(cadcraft-bin)
craft_buildin $name $version
