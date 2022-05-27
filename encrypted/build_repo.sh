#!/usr/bin/env bash

_build_repo() {
    local _profile="encrypted"
    local _pwd="$(pwd)"
    local _server="/tmp/archiso-profiles/${_profile}/any"
    rm -rf repo "${_server}" && mkdir -p repo "${_server}"
    cd repo
    local _pkgname="mkinitcpio-archiso-encryption"
    git clone "https://aur.archlinux.org/${_pkgname}"
    cd "${_pkgname}"
    makepkg
    mv "${_pkgname}"*"any.pkg.tar."* "${_server}"
    cd "${_server}"
    repo-add "${_profile}.any.db.tar.gz" *"any.pkg.tar."*
    cd "${_pwd}"
}

_build_repo
