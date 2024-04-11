
#ifndef _TERMINAL_H_
#define _TERMINAL_H_

#include <stdint.h>
#include <stddef.h>
#include <nstd/string.h>
#include <system/vga.h>

void terminal_initialize(void);
void terminal_setcolor(uint8_t color);
void terminal_putentryat(char c, uint8_t color, size_t x, size_t y);
void terminal_clear_line(size_t y);
void terminal_clear_current_line();
void terminal_shift_rows_up(int amount);
bool terminal_validate_character(char c);
void terminal_putchar(char c);
void terminal_write(const char *data, size_t size);
void terminal_writestring(const char *data);

#endif // _TERMINAL_H_
