MAKEFLAGS=-s

MAKEFILE_DIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ------------
# Dependencies
# ------------

install_dependencies: remove_cross_compiler all_utility all_cross_compiler

# --------------
# Cross-Compiler
# --------------

CROSS_COMPILER_DIR=$(MAKEFILE_DIR)/environment

PREFIX=$(CROSS_COMPILER_DIR)/compiler
TARGET=x86_64-elf
export PATH := $(PREFIX)/bin:$(PATH)

begin_cross_compiler:
	echo $(PATH)
	figlet "Creating Cross-Compiler"
	mkdir -p $(CROSS_COMPILER_DIR)

strip_cross_compiler: clean_binutils_build clean_gdb_build clean_gcc_build clean_m4_build clean_gmp_build clean_mpfr_build clean_mpc_build clean_autoconf_build clean_automake_build clean_texinfo_build clean_libtool_build clean_nasm_build
	echo "Removing Source Files..."
	echo "(1) Binutils"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_BINUTILS)
	echo "(2) GDB"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_GDB)
	echo "(3) GCC"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_GCC)
	echo "(4) GMP"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_GMP)
	echo "(5) MPFR"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_MPFR)
	echo "(6) MPC"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_MPC)
	echo "(7) autoconf"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_AUTOCONF)
	echo "(8) automake"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_AUTOMAKE)
	echo "(9) libtool"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_LIBTOOL)
	echo "(10) texinfo"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_TEXINFO)
	echo "(11) m4"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_M4)
	echo "(12) nasm"
	rm -rf $(CROSS_COMPILER_DIR)/$(SOURCE_NASM)


all_cross_compiler: begin_cross_compiler install_m4 install_autoconf install_automake install_libtool install_gmp install_mpfr install_mpc install_texinfo install_binutils install_gdb install_gcc install_nasm
	echo "Cross-Compiler Created (probably) !"

remove_cross_compiler:
	echo "Removing Cross-Compiler..."
	rm -rf $(CROSS_COMPILER_DIR)

# Binutils

install_binutils: download_binutils build_binutils

SOURCE_BINUTILS=binutils-2.42

download_binutils:
	figlet "Downloading Binutils"
	curl -s "https://ftp.gnu.org/gnu/binutils/$(SOURCE_BINUTILS).tar.bz2" | tar xvjf - -C $(CROSS_COMPILER_DIR)

build_binutils:
	echo "Building Binutils"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_BINUTILS)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_BINUTILS) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_BINUTILS)/configure \
			--target=$(TARGET) \
			--prefix=$(PREFIX) \
			--with-sysroot \
			--disable-nls \
			--disable-werror \
		&& make -j 8 \
		&& make install
	echo "Binutils (probably) Built Successfully !"

clean_binutils_build:
	echo "Purging Binutils Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_BINUTILS)

# GDB

install_gdb: download_gdb build_gdb

SOURCE_GDB=gdb-14.2

download_gdb:
	figlet "Downloading GDB"
	curl -s "https://ftp.gnu.org/gnu/gdb/$(SOURCE_GDB).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_gdb:
	echo "Building GDB"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_GDB)/configure \
			--target=$(TARGET) \
			--prefix=$(PREFIX) \
			--with-gmp=$(PREFIX) \
			--disable-werror \
		&& make -j 8 all-gdb \
		&& make install-gdb
	echo "GDB (probably) Built Successfully !"

clean_gdb_build:
	echo "Purging GDB Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB)

# GCC

install_gcc: download_gcc build_gcc

SOURCE_GCC=gcc-14.1.0
TARGET_AS_LOCATION=$(wildcard $(PREFIX)/bin/$(TARGET)-as)

download_gcc:
	figlet "Downloading GCC"
	curl "https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/$(SOURCE_GCC).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_gcc:
ifneq ($(TARGET_AS_LOCATION) , )
	echo "Building GCC"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_GCC)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_GCC) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_GCC)/configure \
			--target=$(TARGET) \
			--prefix=$(PREFIX) \
			--disable-nls \
			--enable-languages=c,c++ \
			--without-headers \
			--with-gmp=$(PREFIX) \
			--with-mpc=$(PREFIX) \
		&& make -j 8 all-gcc \
		&& make all-target-libgcc \
		&& make install-gcc \
		&& make install-target-libgcc
	echo "GCC (probably) Built Successfully !"
else
	echo "Install Binutils before attempting to build GCC"
endif

clean_gcc_build:
	echo "Purging GCC Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GCC)

# m4 (Needed For GMP)

install_m4: download_m4 build_m4

SOURCE_M4=m4-1.4.19

download_m4:
	figlet "Downloading m4"
	curl "https://ftp.gnu.org/gnu/m4/$(SOURCE_M4).tar.bz2" | tar xvjf - -C $(CROSS_COMPILER_DIR)

build_m4:
	echo "Building m4"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_M4)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_M4) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_M4)/configure \
			--prefix=$(PREFIX) \
			--disable-dependency-tracking \
		&& make -j8 \
		&& make install
	echo "m4 (probably) Built Successfully !"

clean_m4_build:
	echo "Purging m4 Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_M4)

# GMP (Needed For GCC)

install_gmp: download_gmp build_gmp

SOURCE_GMP=gmp-6.3.0

download_gmp:
	figlet "Downloading GMP"
	curl "https://ftp.gnu.org/gnu/gmp/$(SOURCE_GMP).tar.bz2" | tar xvjf - -C $(CROSS_COMPILER_DIR)

build_gmp:
	echo "Building GMP"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_GMP)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_GMP) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_GMP)/configure \
			--prefix=$(PREFIX) \
		&& make -j 8 \
		&& make install \
		&& make check
	echo "GMP (probably) Built Successfully !"

clean_gmp_build:
	echo "Purging GMP Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GMP)

# MPFR (Needed For GCC)

install_mpfr: download_mpfr build_mpfr

SOURCE_MPFR=mpfr-4.2.1

download_mpfr:
	figlet "Downloading MPFR"
	curl "https://ftp.gnu.org/gnu/mpfr/$(SOURCE_MPFR).tar.bz2" | tar xvjf - -C $(CROSS_COMPILER_DIR)

build_mpfr:
	echo "Building MPFR"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPFR)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPFR) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_MPFR)/configure \
			--prefix=$(PREFIX) \
			--disable-dependency-tracking \
			--disable-debug \
			--libdir=$(PREFIX)/lib \
			--with-gmp-include=$(PREFIX)/include/ \
			--with-gmp-lib=$(PREFIX)/lib \
			--disable-silent-rules \
		&& make -j8 \
		&& make check \
		&& make install
	echo "MPFR (probably) Built Successfully !"

clean_mpfr_build:
	echo "Purging MPFR Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPFR)

# MPC

install_mpc: download_mpc build_mpc

SOURCE_MPC=mpc-1.3.1

download_mpc:
	figlet "Downloading MPC"
	curl "https://ftp.gnu.org/gnu/mpc/$(SOURCE_MPC).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_mpc:
	echo "Building MPC"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPC)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPC) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_MPC)/configure \
			--prefix=$(PREFIX) \
			--with-gmp=$(PREFIX) \
		&& make -j 8 \
		&& make install
	echo "MPC (probably) Built Successfully !"

clean_mpc_build:
	echo "Purging MPC Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_MPC)

# libtool (dep. m4)

install_libtool: download_libtool build_libtool

SOURCE_LIBTOOL=libtool-2.4

download_libtool:
	figlet "Downloading libtool"
	curl "https://ftp.gnu.org/gnu/libtool/$(SOURCE_LIBTOOL).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_libtool:
	echo "Building libtool"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_LIBTOOL)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_LIBTOOL) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_LIBTOOL)/configure \
			--disable-dependency-tracking \
			--prefix=$(PREFIX) \
			--enable-ltdl-install \
		&& make -j8 \
		&& make install
	echo "libtool (probably) Build Successfully !"

clean_libtool_build:
	echo "Purging libtool Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_LIBTOOL)

# autoconf (dep. m4, perl)

install_autoconf: download_autoconf build_autoconf

SOURCE_AUTOCONF=autoconf-2.72

download_autoconf:
	figlet "Downloading autoconf"
	curl "https://ftp.gnu.org/gnu/autoconf/$(SOURCE_AUTOCONF).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_autoconf:
	echo "Building autoconf"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOCONF)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOCONF) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_AUTOCONF)/configure \
			--prefix=$(PREFIX) \
		&& make install
	echo "autoconf (probably) Built Successfully !"

clean_autoconf_build:
	echo "Purging autoconf Build"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOCONF)

# automake (dep. autoconf)

install_automake: download_automake build_automake

SOURCE_AUTOMAKE=automake-1.16.5

download_automake:
	figlet "Downloading automake"
	curl "https://ftp.gnu.org/gnu/automake/$(SOURCE_AUTOMAKE).tar.xz" | tar xvJf - -C $(CROSS_COMPILER_DIR)

build_automake:
	echo "Building automake"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOMAKE)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOMAKE) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_AUTOMAKE)/configure \
			--prefix=$(PREFIX) \
		&& make install
	echo "automake (probably) Built Successfully !"

clean_automake_build:
	echo "Purging automake Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_AUTOMAKE)

# texinfo

install_texinfo: download_texinfo build_texinfo

SOURCE_TEXINFO=texinfo-7.1

download_texinfo:
	figlet "Downloading texinfo"
	curl "https://ftp.gnu.org/gnu/texinfo/$(SOURCE_TEXINFO).tar.xz" | tar xvJf - -C $(CROSS_COMPILER_DIR)

build_texinfo:
	echo "Building texinfo"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_TEXINFO)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_TEXINFO) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_TEXINFO)/configure \
			--prefix=$(PREFIX) \
		&& make -j 8 \
		&& make check \
		&& make install
	echo "texinfo (probably) Built Successfully !"

clean_texinfo_build:
	echo "Purging texinfo Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_TEXINFO)

# NASM

install_nasm: download_nasm build_nasm

SOURCE_NASM=nasm-2.16.03

download_nasm:
	echo "Downloading NASM"
	curl "https://www.nasm.us/pub/nasm/releasebuilds/2.16.03/$(SOURCE_NASM).tar.xz" | tar xvJf - -C $(CROSS_COMPILER_DIR)

build_nasm:
	echo "Building NASM"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_NASM)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_NASM) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_NASM)/configure \
			--prefix=$(PREFIX) \
		&& make -j 8 \
		&& make install
	echo "NASM (probably) Built Correctly !"

clean_nasm_build:
	echo "Purging NASM Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_NASM)

# mtools

install_mtools: download_mtools build_mtools

SOURCE_MTOOLS=mtools-4.0.43

download_mtools:
	echo "Downloading mtools"
	curl "https://ftp.gnu.org/gnu/mtools/$(SOURCE_MTOOLS).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_mtools:
	echo "Building mtools"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_MTOOLS)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_MTOOLS) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_MTOOLS)/configure \
			--prefix=$(PREFIX) \
			--disable-debug \
			--without-x \
		&& make -j 8 \
		&& make install
	echo "mtools (probably) Built Successfully !"

clean_mtools_build:
	echo "Purging mtools Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_MTOOLS)

# objconv

install_objconv: download_objconv build_objconv

SOURCE_OBJCONV=objconv

download_objconv:
	echo "Downloading objconv"
	mkdir -p $(CROSS_COMPILER_DIR)/$(SOURCE_OBJCONV)
	cd $(CROSS_COMPILER_DIR)/$(SOURCE_OBJCONV) \
		&& curl "https://www.agner.org/optimize/objconv.zip" -o $(SOURCE_OBJCONV).zip \
		&& unzip $(SOURCE_OBJCONV).zip \
		&& rm $(SOURCE_OBJCONV).zip \
		&& unzip source.zip

build_objconv:
	echo "Building objconv"
	cd $(CROSS_COMPILER_DIR)/$(SOURCE_OBJCONV) \
		&& sh build.sh \
		&& mv objconv $(PREFIX)/bin
	echo "objconv (probably) Built Successfully !"

# grub

install_grub: download_grub build_grub

SOURCE_GRUB=grub

download_grub:
	echo "Download grub"
	cd $(CROSS_COMPILER_DIR) \
		&& git clone --depth 1 git://git.savannah.gnu.org/grub.git

build_grub:
	echo "Building grub"
	cd $(CROSS_COMPILER_DIR)/$(SOURCE_GRUB) \
		&& ./bootstrap
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_GRUB)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_GRUB) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_GRUB)/configure \
			--disable-werror \
			TARGET_CC=$(TARGET)-gcc \
			TARGET_OBJCOPY=$(TARGET)-objcopy \
			TARGET_STRIP=$(TARGET)-strip \
			TARGET_NM=$(TARGET)-nm \
			TARGET_RANLIB=$(TARGET)-ranlib \
			--target=$(TARGET) \
			--prefix=$(PREFIX)
		&& make -j 8 \
		&& make install
	echo "grub (probably) Built Successfully"

clean_grub_build:
	echo "Purging grub Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GRUB)

# -------
# Utility
# -------

UTILITY_DIR := $(CROSS_COMPILER_DIR)/utility
export PATH := $(UTILITY_DIR)/bin:$(PATH)

begin_utility:
	echo "Making Utility"
	mkdir -p $(UTILITY_DIR)

all_utility: begin_utility install_figlet

list:
	echo "usage: make [any target]"
	echo "targets:"
	echo "__cross_compiler__"
	echo "install_dependencies ---> (Re)Make Utility and Cross-Compiler."
	echo "strip_cross_compiler ---> Remove all cross-compiler source files."

# Figlet

install_figlet: download_figlet build_figlet

SOURCE_FIGLET=figlet-2.2.5

download_figlet:
	echo "Downloading Figlet"
	curl "http://ftp.figlet.org/pub/figlet/program/unix/$(SOURCE_FIGLET).tar.gz" | tar xvfz - -C $(UTILITY_DIR)
	echo "Downloading Figlet Fonts"
	mkdir -p $(UTILITY_DIR)/fonts
	curl "http://ftp.figlet.org/pub/figlet/fonts/contributed.tar.gz" | tar xvfz - -C $(UTILITY_DIR)/fonts
	curl "http://ftp.figlet.org/pub/figlet/fonts/international.tar.gz" | tar xvfz - -C $(UTILITY_DIR)/fonts

build_figlet:
	echo "Building Figlet"
	cd $(UTILITY_DIR)/$(SOURCE_FIGLET) \
		&& make \
			prefix=$(UTILITY_DIR) \
			CFLAGS=-Wno-implicit-function-declaration \
			DEFAULTFONTDIR=$(UTILITY_DIR)/fonts \
			install
	echo "Figlet (probably) Built Successfully !"

remove_figlet:
	echo "Purging Figlet Source"
	rm -rf $(UTILITY_DIR)/$(SOURCE_FIGLET)

.PHONY: all_cross_compiler clean_cross_compiler download_binutils
.PHONY: build_binutils clean_binutils_build download_gcc build_gcc
.PHONY: clean_gcc_build download_gdb build_gdb clean_gdb_build download_gmp
.PHONY: build_gmp clean_gmp_build download_mpfr build_mpfr clean_mpfr_build
.PHONY: download_mpc build_mpc clean_mpc_build download_autoconf build_autoconf
.PHONY: clean_autoconf_build download_automake build_automake clean_automake_build
.PHONY: download_libtool build_libtool clean_libtool_build install_binutils install_gcc
.PHONY: install_gdb install_gmp install_mpfr install_mpc install_figlet
.PHONY: download_figlet build_figlet remove_figlet list begin_utility all_utility

