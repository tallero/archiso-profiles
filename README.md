# Archiso profiles

This repository contain additional archiso profiles.
It depends on `archiso-persistent-git` ([`AUR`](https://aur.archlinux.org/packages/archiso-persistent-git)) and .

## Profiles

### `ebaseline` <br> <sub>*`archlinux-ebaseline`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-ebaseline))</sub>
Encryption-enabled replica of `baseline`:
```yaml
- airootfs_image_type: "erofs+luks";
- keys_image_type: "squashfs+luks";
- buildmodes: "iso" and "keys";
- cryptsetup-luks-cryptkey: replaces "cryptsetup";
- mkinitcpio-archiso-encryption: replaces "mkinitcpio-archiso";
```

### `desktopbase` <br> <sub>*`archlinux-desktopbase-git`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktopbase-git))</sub>
Base desktops based on `ebaseline` without apps. Same options as `desktop`.

```yaml
- keys_image_type: erofs+luks
- plymouth-luks-cryptkey: replaces `plymouth`
```

### `desktop` <br> <sub>*`archlinux-desktop`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktop))</sub>
Desktop profile based on `desktopbase`.

#### Apps
- Abiword
- Firefox
- Gnumeric
- gitg
- Marker
- mpv

### `ereleng` <br> <sub>*`archlinux`* ([`AUR`](https://aur.archlinux.org/packages/archlinux))</sub>

Encryption-enabled replica of `releng`:
```yaml
- airootfs_image_type: "squashfs+luks"
- keys_image_type: "erofs+luks";
- buildmodes: "iso" and "keys"
- cryptsetup-luks-cryptkey: replaces "cryptsetup"
- mkinitcpio-archiso-encryption: replaces "mkinitcpio-archiso"
```

## Download

The profiles can be built and downloaded online on
[Google Colab](https://colab.research.google.com/github/tallero/archiso-profiles/blob/noapps/jupyter/jupyter.ipynb).

## Build

As with any other Archiso profile:

```console
$ cd archiso-profiles/<profile>
$ ../.gitlab/ci/build_repo.sh src
# mkarchiso -v ./ 
```

# License

All the code is released under GNU Affero General Public License version 3.
