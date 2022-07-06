#!/usr/bin/env bash

_setup_user() {
  useradd user
  mkdir -p /home/user
  chown -R user /home/user
  chmod 700 /home/user
}

_setup_user
