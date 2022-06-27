_install_arch_install_scripts() {
    sudo apt install build-essentials git
    git clone https://github.com/archlinux/arch-install-scripts
    make -C "$pkgname"
    sudo make -C "$pkgname" PREFIX=/usr DESTDIR="/" install
}

_install_arch_install_scripts
