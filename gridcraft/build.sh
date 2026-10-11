#!/bin/bash
set -e
name=gridcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Microsoft Excel."
homepage="https://getartcraft.com/apps/gridcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
craft_buildin $name $version

