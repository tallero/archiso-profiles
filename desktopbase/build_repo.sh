#!/usr/bin/env bash

_build_pkg() {
    local _pwd
    _pwd="$(pwd)"
    local _pkgname="${1}"
    git clone "https://aur.archlinux.org/${_pkgname}"
    cd "${_pkgname}" || exit
    makepkg
    mv "${_pkgname}"*".pkg.tar."* "${_server}"
    cd "${_server}" || exit
    repo-add "${_profile}.db.tar.gz" "${_pkgname}"*".pkg.tar."*
    cd "${_pwd}" || exit
}

_build_repo() {
    local _profile
    _profile=$(basename "$(pwd)")
    local _server="/tmp/archiso-profiles/${_profile}"
    rm -rf repo "${_server}" && mkdir -p repo "${_server}"
    cd repo || exit
    gpg --recv-keys "D9B0577BD93E98FC" # cryptsetup
    _build_pkg "cryptsetup-nested-cryptkey"
    _build_pkg "mkinitcpio-archiso-encryption"
    _build_pkg "plymouth-nested-cryptkey"
    _build_pkg "archiso-encryption-git"
    cd ..
    rm -rf repo
}

_build_repo
