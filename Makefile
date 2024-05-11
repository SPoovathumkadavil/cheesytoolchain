MAKEFLAGS=-s

MAKEFILE_DIR:=$(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# --------------
# Cross-Compiler
# --------------

CROSS_COMPILER_DIR=$(MAKEFILE_DIR)/crosscompiler

PREFIX=$(CROSS_COMPILER_DIR)/compiler
TARGET=x86_64-elf
export PATH := $(PREFIX):$(PATH)

begin_cross_compiler:
	echo "Creating Cross-Compiler"
	rm -rf $(CROSS_COMPILER_DIR)
	mkdir -p $(CROSS_COMPILER_DIR)

clean_cross_compiler: clean_binutils_build clean_gdb_build clean_gcc_build

all_cross_compiler: begin_cross_compiler download_binutils download_gcc download_gdb build_binutils build_gcc build_gdb clean_cross_compiler
	echo "Cross-Compiler Created (probably) !"
remove_cross_compiler:
	echo "Removing Cross-Compiler..."
	rm -rf $(CROSS_COMPILER_DIR)

# Binutils

SOURCE_BINUTILS=binutils-2.42

download_binutils:
	echo "Downloading Binutils"
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
		&& make \
		&& make install
	echo "Binutils (probably) Built Successfully!"

clean_binutils_build:
	echo "Purging Binutils Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_BINUTILS)

# GDB

SOURCE_GDB=gdb-14.2

download_gdb:
	echo "Downloading GDB"
	curl -s "https://ftp.gnu.org/gnu/gdb/$(SOURCE_GDB).tar.gz" | tar xvfz - -C $(CROSS_COMPILER_DIR)

build_gdb:
	echo "Building GDB"
	mkdir -p $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB)
	cd $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB) \
		&& $(CROSS_COMPILER_DIR)/$(SOURCE_GDB)/configure \
			--target=$(TARGET) \
			--prefix=$(PREFIX) \
			--disable-werror \
		&& make all-gdb \
		&& make install-gdb
	echo "GDB (probably) Built Successfully!"

clean_gdb_build:
	echo "Purging GDB Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GDB)

# GCC

SOURCE_GCC=gcc-14.1.0
TARGET_AS_LOCATION=$(wildcard $(PREFIX)/bin/$(TARGET)-as)

download_gcc:
	echo "Downloading GCC"
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
		&& make all-gcc \
		&& make all-target-libgcc \
		&& make install-gcc \
		&& make install-target-libgcc
	echo "GCC (probably) Built Successfully!"
else
	echo "Install Binutils before attempting to build GCC"
endif

clean_gcc_build:
	echo "Purging GCC Build Files"
	rm -rf $(CROSS_COMPILER_DIR)/build-$(SOURCE_GCC)

# -------
# Utility
# -------

list:
	echo "usage: make [any target]"
	echo "targets:"
	echo "__cross_compiler__"
	echo "all_cross_compiler   ---> Download, Build (and install) Binutils, GDB, GCC,"
	echo "                          then clean build files."
	echo "clean_cross_compiler ---> Remove all build files from Binutils, GDB, GCC"
	echo "download_binutils    ---> Downloads and Extracts binutils"
	echo "build_binutils_build ---> Builds downloaded binutils and installs binaries"
	echo "                          into main compiler directory"
	echo "clean_binutils       ---> Removes build directory (from the build step)"
	echo "download_gcc         ---> Downloads and Extracts gcc"
	echo "build_gcc_build      ---> Builds downloaded gcc and installs binaries"
	echo "                          into main compiler directory (binutils required)"
	echo "clean_gcc            ---> Removes build directory (from the build step)"
	echo "download_gdb         ---> Downloads and Extracts gdb"
	echo "build_gdb_build      ---> Builds downloaded gdb and installs binaries"
	echo "                          into main compiler directory (binutils required)"
	echo "clean_gdb_build      ---> Removes build directory (from the build step)"

.PHONY: all_cross_compiler clean_cross_compiler download_binutils build_binutils clean_binutils_build download_gcc build_gcc clean_gcc_build download_gdb build_gdb clean_gdb_build

