#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "kernel.h"
#include "system/terminal.h"

#if defined(__linux__) && defined(COMPILING)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

#if !defined(__i386__) && defined(COMPILING)
#error "This needs to be compiled with a ix86-elf compiler"
#endif

void kernel_main(void)
{
    /* Initialize terminal interface */
    terminal::initialize();
    terminal::write_string("hello\n\n\n\n\nhello");
}