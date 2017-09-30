#!/bin/bash
makepkg -g >> PKGBUILD && makepkg -f || rm -rf *.patch src/*.patch
