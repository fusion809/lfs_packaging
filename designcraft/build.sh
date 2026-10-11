#!/bin/bash
set -e
name=designcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe InDesign."
homepage="https://getartcraft.com/apps/designcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
craft_buildin $name $version
