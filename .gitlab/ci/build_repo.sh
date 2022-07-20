#!/usr/bin/env bash

unset mode

_makepkg() {
    local _pkgname="${1}"
    git clone "https://aur.archlinux.org/${_pkgname}"
    cd "${_pkgname}" || exit
    makepkg
    mv "${_pkgname}"*".pkg.tar."* "${_server}"
}

_build_pkg() {
    local _pkgname="${1}"
    local _mode="${2}"
    local _pwd
    _pwd="$(pwd)"

    if [ "${_mode}" = "src" ]; then
        _makepkg "${_pkgname}"
    elif [ "${_mode}" = "fakepkg" ]; then
        cd "${_server}" || exit
        fakepkg "${_pkgname}"
    fi

    cd "${_server}" || exit
    repo-add "${_profile}.db.tar.gz" "${_pkgname}"*".pkg.tar."*
    cd "${_pwd}" || exit
}

_build_repo() {
    local _mode="${1}"
    local _packages="${2}"
    local _profile
    local _pwd
    _pwd=$(pwd)
    _profile=$(basename "$(pwd)")
    # shellcheck source=./packages.extra
    # shellcheck disable=SC1091
    source "${_pwd}/${_packages}"
    local _server="/tmp/archiso-profiles/${_profile}"
    rm -rf repo "${_server}" && mkdir -p repo "${_server}"
    cd repo || exit
    gpg --recv-keys "D9B0577BD93E98FC" # cryptsetup
    # shellcheck disable=SC2154
    for _pkg in "${packages[@]}"; do
        _build_pkg "${_pkg}" "${_mode}"
    done
    cd ..
    rm -rf repo
}

# mode, packages.extra
_build_repo "${1}" "${2}"
