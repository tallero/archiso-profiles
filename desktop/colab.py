#@title Build `releng`
#@markdown Builds the archlinux install image.

def install_deps():
  !sudo apt install autopoint asciidoc bsdtar build-essential cmake dosfstools fakeroot gnulib help2man intltool libarchive-dev libtool libzstd-dev m4 make mtools git grub2 python-pip shellcheck squashfs-tools texinfo zstd #>/dev/null 2>&1
  !sudo pip install meson ninja >/dev/null 2>&1

def install_arch_install_scripts():
  !git clone https://github.com/archlinux/arch-install-scripts >/dev/null 2>&1
  !make -C arch-install-scripts > /dev/null 2>&1
  !sudo make -C arch-install-scripts PREFIX=/usr DESTDIR="/" install > /dev/null 2>&1

def install_asp():
  !git clone https://github.com/falconindy/asp.git >/dev/null 2>&1
  !make -C asp >/dev/null 2&1
  !sudo make -C asp PREFIX=/usr DESTDIR="" install >/dev/null 2>&1
  !sudo install -Dm644 asp/LICENSE "/usr/share/licenses/asp/LICENSE" >/dev/null 2>&1

def install_pacman():
  # !rm -rf pacman
  !mkdir /etc/pacman.d
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/pacman/pacman >/dev/null 2>&1
  
  !cd pacman && meson --prefix=/usr --buildtype=plain -Ddoc=disabled -Ddoxygen=disabled -Dscriptlet-shell=/usr/bin/bash -Dldconfig=/usr/bin/ldconfig build >/dev/null 2>&1
  !cd pacman && meson compile -C build >/dev/null 2>&1
  !cd pacman && sudo DESTDIR="/" meson install -C build >/dev/null 2>&1

  # install Arch specific stuff
  !cd pacman && sudo install -dm755 "/etc" >/dev/null 2&1
  !cd pacman && sudo install -m644 "build/pacman.conf" "/etc" >/dev/null 2>&1
  !cd pacman && sudo install -m644 "build/makepkg.conf" "/etc" >/dev/null 2>&1

  !echo "Server = https://geo.mirror.pkgbuild.com/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
  !sudo sed '/SigLevel/d' archiso/configs/releng/pacman.conf > /etc/pacman.conf
  !sudo pacman-key --init
  !sudo pacman -Sy

def install_archiso():
  !rm -rf archiso
  !git clone https://gitlab.archlinux.org/tallero/archiso archiso >/dev/null 2>&1
  !git checkout -C archiso -b crypto >/dev/null 2>&1
  !cd archiso && make -k check >/dev/null 2>&1
  !cd archiso && make DESTDIR="" PREFIX='/usr' install >/dev/null 2>&1

def install_zstd():
  !rm -rf zstd-1.5.2
  #!git clone https://github.com/facebook/zstd >/dev/null 2>&1
  !wget https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz
  !tar -xf zstd-1.5.2.tar.gz
  #!cd zstd-1.5.2 && ./configure --prefix=/usr
  !cd zstd-1.5.2 && CFLAGS+=' -ffat-lto-objects' && CXXFLAGS+=' -ffat-lto-objects' cmake -S build/cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=None -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib -DZSTD_BUILD_CONTRIB=ON -DZSTD_BUILD_STATIC=OFF -DZSTD_BUILD_TESTS=OFF -DZSTD_PROGRAMS_LINK_SHARED=ON && cmake --build build
  !cd zstd-1.5.2 && DESTDIR="${pkgdir}" cmake --install build
  !cd zstd-1.5.2 && ln -sf /usr/bin/zstd "${pkgdir}/usr/bin/zstdmt"
  #!cd zstd-1.5.2 && make >/dev/null 2>&1
  #!cd zstd-1.5.2 && sudo DESTDIR="/" PREFIX="/usr" make install >/dev/null 2>&1
  #!cp -r "/content/zstd/lib" /usr

def install_gettext():
  # !git clone https://git.savannah.gnu.org/git/gettext.git
  !wget https://ftp.gnu.org/gnu/gettext/gettext-0.21.tar.xz >/dev/null 2>&1
  !tar xf gettext-0.21.tar.xz >/dev/null 2>&1
  # !cd gettext-0.21 && git checkout eb83efc3b58d690d444da0b82c3ecf36a54f28ac
  !cd gettext-0.21 && autoreconf -i >/dev/null 2>&1
  !cd gettext-0.21 && ./configure --prefix=/usr >/dev/null 2>&1
  !cd gettext-0.21 && make >/dev/null 2>&1
  !cd gettext-0.21 && sudo DISTDIR="/" make install >/dev/null 2>&1

def install_autoconf():
  !git clone https://git.savannah.gnu.org/git/autoconf.git >/dev/null 2>&1
  !cd autoconf && autoreconf -i >/dev/null 2>&1
  !cd autoconf && ./configure --prefix=/usr >/dev/null 2>&1
  !cd autoconf && make >/dev/null 2>&1
  !cd autoconf && sudo DESTDIR="/" PREFIX="/usr" make install >/dev/null 2>&1

def install_tar():
  !apt-get build-dep tar >/dev/null 2>&1
  !wget https://ftp.gnu.org/gnu/tar/tar-1.34.tar.xz >/dev/null 2>&1
  !tar -xf tar-1.34.tar.xz >/dev/null 2>&1
  # !git clone https://git.savannah.gnu.org/git/tar.git
  #!cd tar-1.34 && autoreconf -i
  !cd tar-1.34 && FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/usr
  !cd tar-1.34 && make
  !cd tar-1.34 && DESTDIR=/ PREFIX=/usr make install

def install_cmake():
  # !rm -rf cmake-3.23.2
  !wget https://github.com/Kitware/CMake/releases/download/v3.23.2/cmake-3.23.2.tar.gz >/dev/null 2>&1
  !tar xf cmake-3.23.2.tar.gz
  !cd cmake-3.23.2 && ./configure --prefix=/usr >/dev/null 2>&1
  !cd cmake-3.23.2 && make #>/dev/null 2>&1
  !cd cmake-3.23.2 && sudo DESTDIR="/" PREFIX="/usr" make install #>/dev/null 2>&1

def install_libarchive():
  !wget https://github.com/libarchive/libarchive/releases/download/v3.6.1/libarchive-3.6.1.tar.xz
  !tar xf libarchive-3.6.1.tar.xz
  !cd libarchive-3.6.1 && ./configure --prefix=/usr
  !cd libarchive-3.6.1 && make
  !cd libarchive-3.6.1 && DESTDIR="/" PREFIX="/usr" sudo make install 

def install_reflector():
  !rm -rf reflector
  !git clone https://gitlab.archlinux.org/tallero/reflector
  !cd reflector && python3 setup.py install --prefix=/usr --root="/" --optimize=1
  !cd reflector && install -Dm644 "man/reflector.1.gz" "/usr/share/man/man1/reflector.1.gz"
  !cd reflector && install -Dm644 'reflector.service' "/usr/lib/systemd/system/reflector.service"
  !cd reflector && install -Dm644 'reflector.timer' "/usr/lib/systemd/system/reflector.timer"
  !cd reflector && install -Dm644 'reflector.conf' "/etc/xdg/reflector/reflector.conf"

def build_releng():
  # Ask on repository for this
  !sed "/SigLevel/d" archiso/configs/releng/pacman.conf > pacman.conf
  !cp pacman.conf /etc/pacman.conf
  !cp pacman.conf archiso/configs/releng/pacman.conf

  !cd archiso/configs/releng && rm -rf work out
  !cd archiso/configs/releng && mkarchiso -v .

def build_ereleng():
  # Build an encrypted releng
  !rm -rf archiso-profiles >/dev/null 2>&1
  !git clone https://gitlab.archlinux.org/tallero/archiso-profiles >/dev/null 2>&1
  !useradd user >/dev/null 2>&1
  !chown -R user:user archiso-profiles /tmp
  !su user -c "cd archiso-profiles/ereleng && bash build_repo.sh"
  #!cd archiso-profiles/desktop && bash build_repo.sh

install_deps()
install_arch_install_scripts()
install_asp()
install_zstd()
install_gettext()
install_autoconf()
install_tar()
install_cmake()
install_libarchive()
install_pacman()
install_archiso()
install_reflector()
build_releng()
#build_ereleng()

