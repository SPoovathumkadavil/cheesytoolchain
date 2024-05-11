
# NOTE: $@ is right of the :, and $< is the left
MAKEFLAGS = -s #silent

BIN_DIR = bin
INCL_DIR = kernel/include
OBJ_DIR = build
ISODIR = isodir
ISODIR_BOOT = isodir/boot
ISODIR_GRUB = isodir/boot/grub

BUILD_ARCHITECTURE = i386

SRC_DIR = kernel/$(BUILD_ARCHITECTURE)
BOOT_DIR = $(SRC_DIR)/boot

C_SRC_FILES := $(wildcard $(SRC_DIR)/*.c) $(wildcard $(SRC_DIR)/*/*.c) $(wildcard $(SRC_DIR)/*/*/*.c)
CPP_SRC_FILES := $(wildcard $(SRC_DIR)/*.cpp) $(wildcard $(SRC_DIR)/*/*.cpp) $(wildcard $(SRC_DIR)/*/*/*.cpp)
ASM_SRC_FILES := $(wildcard $(SRC_DIR)/*.s) $(wildcard $(SRC_DIR)/*/*.s) $(wildcard $(SRC_DIR)/*/*/*.s)
BOOT_FILES := $(wildcard $(BOOT_DIR)/*.asm) # exclusively boot files

SRC_FILES := $(ASM_SRC_FILES) $(C_SRC_FILES) $(CPP_SRC_FILES)
OBJ_FILES := $(subst $(SRC_DIR), $(OBJ_DIR), $(addsuffix .o, $(basename $(SRC_FILES))))

OUT = $(BIN_DIR)/meows.bin
OUT_ISO = $(addsuffix .iso, $(basename $(OUT)))

# C and Cpp Common Flags
COMMON_FLAGS = -g -c -O2 -ffreestanding -DCOMPILING -lgcc -fno-pic -Werror -Wall -Wextra -I$(INCL_DIR)

CC = i686-elf-gcc
CFLAGS = -std=gnu99 $(COMMON_FLAGS)

CPP = i686-elf-c++
CPPFLAGS = -fno-exceptions -std=c++17 $(COMMON_FLAGS) -fno-rtti

LDFLAGS = -T $(SRC_DIR)/linker.ld -ffreestanding -O2 -lgcc -nostdlib

ASM = nasm
ASM_FLAGS = -felf32 -F dwarf -g

build : $(OUT)

$(OUT) : $(OBJ_FILES)
	echo The files: $(OBJ_FILES)
	$(CC) $(LDFLAGS) $(OBJ_DIR)/boot.o $(OBJ_FILES) -o $(OUT)
	echo "Linking $(OBJ_FILES) ----------> $@"

# assemble any .asm files and put them in the OBJS_DIR
$(OBJ_DIR)/%.o : $(SRC_DIR)/%.asm
	mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) $< -o $@
	echo "$<  ----->  $@"

#compile any .c files and put them in the OBJS_DIR
$(OBJ_DIR)/%.o : $(SRC_DIR)/%.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@
	echo "$<  ----->  $@"

#compiile and .cpp files and put them in the OBJS_DIR
$(OBJ_DIR)/%.o : $(SRC_DIR)/%.cpp
	mkdir -p $(dir $@)
	$(CPP) $(CPPFLAGS) $< -o $@
	echo "$<  ----->  $@"

files:
	echo "<----- .asm ----->"
	echo $(ASM_SRC_FILES) "\n"
	echo "<----- .c ----->"
	echo $(C_SRC_FILES) "\n"
	echo "<----- .cpp ----->"
	echo $(CPP_SRC_FILES)  "\n"
	echo "<----- objects ----->"
	echo $(OBJ_FILES) "\n"
	echo "<----- Output File ----->"
	echo $(OUTPUT_FILE)

#.PHONY tells make that there will never be these files
.PHONY: clean print run all list files

list:
	echo "list    ---> list all options"
	echo "build   ---> build any changes"
	echo "clean   ---> remove all compiled files"
	echo "rebuild ---> clean, then build RUN THIS!!"
	echo "run     ---> run virtual test"
	echo "all     ---> clean, build, then run"
	echo "files   ---> show what source files will be used when building"
	echo "print   ---> prints a the name of a the a thing"
	echo "biso    ---> builds the iso from the .bin file"
	echo "bboot   ---> builds the boot.o"

bboot:
	$(ASM) $(ASM_FLAGS) $(BOOT_FILES) -o $(OBJ_DIR)/boot.o

biso:
	mkdir -p $(ISODIR_GRUB)
	cp $(OUT) $(ISODIR_BOOT)/$(notdir $(OUT))
	cp $(SRC_DIR)/grub.cfg $(ISODIR_GRUB)/grub.cfg
	grub-mkrescue -o $(OUT_ISO) $(ISODIR)

rebuild: print clean bboot build biso
	echo "Full Clean and Make done..."

all: rebuild run

clean:
	echo "Clean up..."
	rm -rf $(OBJ_DIR)
	mkdir build
	rm -f $(BIN_DIR)/*~ $(BIN_DIR)/*.bin

print:
	# don't fail if figlet isn't installed
	if which figlet >/dev/null; then figlet -c meOwS; else echo "                        ##### meOwS #####"; fi

run:
	echo "Starting QEMU"
	qemu-system-i386 -cdrom $(OUT_ISO)

