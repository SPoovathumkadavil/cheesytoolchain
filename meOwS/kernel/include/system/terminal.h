
#ifndef _TERMINAL_H_
#define _TERMINAL_H_

#include <stdint.h>
#include <stddef.h>
#include <nstd/string.h>
#include <system/vga.h>

class terminal
{
public:
    static void initialize(void);
    static void setcolor(uint8_t color);
    static void putentryat(char c, uint8_t color, size_t x, size_t y);
    static void clear_line(size_t y);
    static void clear_current_line();
    static void shift_rows_up(int amount);
    static bool validate_character(char c);
    static void putchar(char c);
    static void write(const char *data, size_t size);
    static void writestring(const char *data);
};

#endif // _TERMINAL_H_
