#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="archlinux"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Arch Linux <https://archlinux.org>"
iso_application="Arch Linux Live/Rescue CD"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso' 'dongle')
images=(["cdr"]="700000:iso:1"
	["dvd"]="4200000:iso:1"
	["ssd"]="120000000:iso:1"
	["usb"]="64000000:dongle:1")
bootmodes=('bios.grub.mbr'
           'bios.grub.eltorito'
	   'uefi-ia32.grub.esp'
           'uefi-ia32.grub.eltorito'
           'uefi-x64.grub.esp'
           'uefi-x64.grub.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="erofs+luks"
airootfs_image_tool_options=('-zlz4hc,12' -E ztailpacking)
encryption_key="auto"
persistent_size=500000 # 500 MB
persistent_image_type="ext4+luks"
persistent_encryption_key="auto"
dongle_persistent_encryption_key="auto"
swap_size=250000 # 250 MB
swap_image_type="swap"
keys_image_type="erofs"
keys_image_tool_options=('-zlz4hc,12' -E ztailpacking)
file_permissions=(
  ["/etc/crypttab"]="0:0:400"
  ["/etc/shadow"]="0:0:400"
  ["/home"]="0:0:711"
  ["/root"]="0:0:700"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/run/archiso/keys"]="0:0:700"
  ["/run/archiso/persistent"]="0:0:711"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/setup-persistent-storage"]="0:0:755"
  ["/usr/local/bin/user-setup"]="0:0:755"
  ["/usr/local/bin/resolve-dev-mapper-donglepersistent"]="0:0:755"
  ["/usr/local/bin/resolve-dev-mapper-persistent"]="0:0:755"
  ["/var/lib/bluetooth"]="0:0:755"
)
