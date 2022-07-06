# Archiso profiles

This repository contain additional archiso profiles.
It depends on `archiso-persistent-git` ([`AUR`](https://aur.archlinux.org/packages/archiso-persistent-git)).

## Profiles

### `desktop` <br> <sub>*`archlinux-desktop`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktop))</sub>
Desktop profile.

```yaml
- airootfs_image_type: erofs+luks
- keys_image_type: erofs+luks
- buildmodes: `iso` and `keys`
- cryptsetup-luks-cryptkey: replaces `cryptsetup`
- plymouth-luks-cryptkey: replaces `plymouth`
- mkinitcpio-archiso-encryption: replaces `mkinitcpio-archiso`
```

#### Apps
- Abiword
- Firefox
- Gnumeric
- gitg
- Marker
- mpv

### `desktopbase` <br> <sub>*`archlinux-desktopbase-git`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-desktopbase-git))</sub>
Base desktops without apps. Same options as `desktop`.

### `ereleng` <br> <sub>*`archlinux`* ([`AUR`](https://aur.archlinux.org/packages/archlinux))</sub>

Encryption-enabled replica of `releng`:
```yaml
- `airootfs_image_type`: `squashfs+luks`;
- `keys_image_type`: `erofs+luks`;
- `buildmodes`: `iso` and `keys`;
- `cryptsetup-luks-cryptkey`: replaces `cryptsetup`;
- `mkinitcpio-archiso-encryption`: replaces `mkinitcpio-archiso`;
```

### `ebaseline` <br> <sub>*`archlinux-ebaseline`* ([`AUR`](https://aur.archlinux.org/packages/archlinux-ebaseline))</sub>
Encryption-enabled replica of `baseline`:
```yaml
- `airootfs_image_type`: `erofs+luks`;
- `keys_image_type`: `squashfs+luks`;
- `buildmodes`: `iso` and `keys`;
- `cryptsetup-luks-cryptkey`: replaces `cryptsetup`;
- `mkinitcpio-archiso-encryption`: replaces `mkinitcpio-archiso`;
```

## Download

The profiles can be built and downloaded online on
[Google Colab](https://colab.research.google.com/github/tallero/archiso-profiles/blob/noapps/jupyter/jupyter.ipynb).

## Build

As any other Archiso profile:

```console
$ cd profile
$ ../gitlab/ci/build_repo.sh src
# mkarchiso -v ./ 
```

# License

All the code is released under AGPLv3.
