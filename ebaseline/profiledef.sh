#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux-ebaseline"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux baseline"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso' 'keys')
bootmodes=('bios.syslinux.mbr'
           'bios.syslinux.eltorito'
	   'uefi-ia32.grub.esp'
           'uefi-ia32.grub.eltorito'
           'uefi-x64.systemd-boot.esp'
           'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs+luks"
airootfs_image_tool_options=('-zlz4hc,12')
encryption_key="auto"
keys_image_type="erofs"
keys_image_tool_options=('-zlz4hc,12')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/run/archiso/keys"]="0:0:700"
)
