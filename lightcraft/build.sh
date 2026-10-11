#!/bin/bash
set -e
name=lightcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe Lightroom."
homepage="https://getartcraft.com/apps/lightcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
craft_buildin $name $version