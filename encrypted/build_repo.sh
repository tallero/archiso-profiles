#!/usr/bin/env bash

_build_pkg() {
    local _pwd="$(pwd)"
    local _pkgname="${1}"
    cd "${_pkgname}"
    makepkg
    mv "${_pkgname}"*".pkg.tar."* "${_server}"
    cd "${_pwd}"
}

_build_repo() {
    local _profile="encrypted"
    local _pwd="$(pwd)"
    local _server="/tmp/archiso-profiles/${_profile}/any"
    rm -rf repo "${_server}" && mkdir -p repo "${_server}"
    cd repo
    _build_pkg "cryptsetup-nested-cryptkey"
    _build_pkg "mkinitcpio-archiso-encryption"
    cd "${_server}"
    repo-add "${_profile}.db.tar.gz" *".pkg.tar."*
    cd "${_pwd}"
    rm -rf repo
}

_build_repo
