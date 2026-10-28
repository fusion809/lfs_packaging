#!/bin/bash
set -e
name=artcraft-launcher
repo=storytold/${name/art/}
description="Launcher for ArtCraft apps."
homepage="https://getartcraft.com/apps"
version=$(gh_ver $repo)
depends=(gcc glibc)
conflicts=(artcraft-launcher-bin)
craft_buildin $name $version
