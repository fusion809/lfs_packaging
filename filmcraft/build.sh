#!/bin/bash
set -e
name=filmcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Adobe Premiere Pro."
homepage="https://getartcraft.com/apps/filmcraft"
version=$(gh_ver $repo)
depends=(alsa-lib gcc glibc)
conflicts=(filmcraft-bin)
craft_buildin $name $version

