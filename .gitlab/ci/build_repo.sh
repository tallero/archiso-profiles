#!/usr/bin/env bash

unset mode

_makepkg() {
    local _pkgname="${1}"
    local _repo="${2}"
    local _user="${3}"
    if [[ "${_repo}" == "" ]] || [[ "${_repo}" == "aur" ]] ; then
        _url="https://aur.archlinux.org"
    elif [ "${_repo}" == "archlinux" ]; then
        _url="https://gitlab.archlinux.org/${_user}/${_pkgname}-aur"
    fi
    git clone "${_url}/${_pkgname}"
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
    local _server="${3}"
    local _profile
    local _pwd
    _pwd=$(pwd)
    _profile=$(basename "$(pwd)")
    # shellcheck source=./packages.extra
    # shellcheck disable=SC1091
    source "${_pwd}/${_packages}"
    if [[ "${_server}" == "" ]]; then
        _server="/tmp/archiso-profiles/${_profile}"
    fi
    rm -rf repo "${_server}"
    mkdir -p repo "${_server}"
    chown "$(id -u):$(id -g)" "${_server}"
    chmod 700 "${_server}" 
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
_build_repo "${1}" "${2}" "${3}"
