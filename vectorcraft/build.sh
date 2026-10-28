#!/bin/bash
set -e
name=vectorcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe Illustrator."
homepage="https://getartcraft.com/apps/vectorcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
conflicts=(vectorcraft-bin)
craft_buildin $name $version
