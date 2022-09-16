#!/usr/bin/env bash

## shellcheck disable=SC2154
_setup_PKGBUILD() {
  local _distro="${1}"
  local distro="${2}"
  local profile="${3}"
  local _uuidgen="./uuidgen"
  chmod +x "${_uuidgen}"
  sed "s|%_DISTRO%|${_distro}|g;
       s|%DISTRO%|${distro}|g;
       s|%PROFILE%|${profile}|g" "PKGBUILD.template" > "PKGBUILD"
}

_distro="${1}"
distro="${2}"
profile="${3}"

_setup_PKGBUILD "${_distro}" "${distro}" "${profile}"
