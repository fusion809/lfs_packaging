#!/bin/bash
set -e
name=photocraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe Photoshop."
homepage="https://getartcraft.com/apps/photocraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
conflicts=(photocraft-bin)
craft_buildin $name $version
