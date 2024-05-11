
#ifndef _TERMINAL_H_
#define _TERMINAL_H_

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <system/vga.h>
#include <nstd/string.h>

namespace system
{
    class terminal
    {
    public:
        // The terminal's row.
        static size_t terminal_row;
        // The terminal's column.
        static size_t terminal_column;
        // The terminal's color.
        static uint8_t terminal_color;
        // The terminal's buffer.
        static uint16_t *terminal_buffer;

        // Gets the length of a buffer.
        static size_t buflen(const uint16_t *buf);

        // Initializes the terminal.
        static void initialize(void);

        // Sets the terminal's color.
        static void set_color(uint8_t color);

        // Puts an entry at a specific location.
        static void put_entryat(char c, uint8_t color, size_t x, size_t y);

        // Clears a line.
        static void clear_line(size_t y);

        // Shifts the terminal's buffer.
        static void shift_rowsup();

        // Clears the current line.
        static void clear_currentline();

        // Clears the terminal's buffer.
        static void clear_buffer();

        // Writes a character to the terminal.
        static void put_char(char c);

        // Write a string given string and size
        static void write(const char *data, size_t size);

        // Writes a string to the terminal.
        static void write_string(const char *data);

        // Writes a centered string to the terminal.
        static void write_centeredstring(const char *data);

        // Prints the splash screen.
        static void print_splash();
    };
}

#endif // _TERMINAL_H_
