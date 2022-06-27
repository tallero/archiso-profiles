def install_deps():
  !sudo apt install asciidoc bsdtar build-essential cmake dosfstools fakeroot libarchive-dev m4 make mtools git grub2 python-pip shellcheck squashfs-tools >/dev/null 2>&1
  !sudo pip install meson ninja >/dev/null 2>&1

def install_arch_install_scripts():
  !git clone https://github.com/archlinux/arch-install-scripts >/dev/null 2>&1
  !make -C arch-install-scripts > /dev/null 2>&1
  !sudo make -C arch-install-scripts PREFIX=/usr DESTDIR="/" install > /dev/null 2>&1


def install_asp():
  !git clone https://github.com/falconindy/asp.git >/dev/null 2>&1
  !make -C asp >/dev/null 2&1
  !sudo make -C asp PREFIX=/usr DESTDIR="/" install >/dev/null 2>&1
  !sudo install -Dm644 asp/LICENSE "/usr/share/licenses/asp/LICENSE" >/dev/null 2>&1

def install_pacman():
  # !rm -rf pacman
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/pacman/pacman >/dev/null 2>&1
  !cd pacman && meson --prefix=/usr --buildtype=plain -Ddoc=disabled -Ddoxygen=disabled -Dscriptlet-shell=/usr/bin/bash -Dldconfig=/usr/bin/ldconfig build >/dev/null 2>&1
  !cd pacman && meson compile -C build >/dev/null 2>&1
  !cd pacman && DESTDIR="/" meson install -C build >/dev/null 2>&1

  # install Arch specific stuff
  !cd pacman && install -dm755 "/etc" >/dev/null 2&1
  !cd pacman && install -m644 "build/pacman.conf" "/etc" >/dev/null 2>&1
  !cd pacman && install -m644 "build/makepkg.conf" "/etc" >/dev/null 2>&1
  !echo "Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch" > /etc/pacman.d/mirrorlist
  !sudo pacman-key --init
  !sudo pacman -Sy

def install_archiso():
  !rm -rf archiso
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !ls archiso
  !git checkout -C archiso -b crypto >/dev/null 2>&1
  !cd archiso && make -k check >/dev/null 2>&1
  !cd archiso && make DESTDIR="/" PREFIX='/usr' install >/dev/null 2>&1

def install_reflector():
  !rm -rf /home/user/reflector
  !useradd user >/dev/null 2>&1
  !mkdir /home/user && chown -R user:user /home/user
  !su user -c "cd /home/user/ && asp checkout reflector"
  !su user -c "cd /home/user/reflector/trunk && makepkg"

def build_releng():
  !cp /usr/share/archiso/configs/releng/pacman.conf /etc
  !stat /etc/pacman.conf
  !cd /usr/share/archiso/configs/releng && mkarchiso -v .

def build_ereleng():
  !asp checkout reflector
  !rm -rf archiso-profiles >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/tallero/archiso-profiles >/dev/null 2>&1
  !useradd user >/dev/null 2>&1
  !chown -R user:user archiso-profiles /tmp
  !su user -c "cd archiso-profiles/ereleng && bash build_repo.sh"
  #!cd archiso-profiles/desktop && bash build_repo.sh


install_deps()
#install_arch_install_scripts()
#install_asp()
#install_pacman()
#install_archiso()
#install_reflector()
build_releng()
#build_ereleng()
