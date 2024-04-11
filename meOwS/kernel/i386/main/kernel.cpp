#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "kernel.h"

#if defined(__linux__) && defined(COMPILING)
#error "You are not using a cross-compiler, you will most certainly run into trouble"
#endif

#if !defined(__i386__) && defined(COMPILING)
#error "This needs to be compiled with a ix86-elf compiler"
#endif

/* Hardware text mode color constants. */
enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};

static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg)
{
	return fg | bg << 4;
}

static inline uint16_t vga_entry(unsigned char uc, uint8_t color)
{
	return (uint16_t) uc | (uint16_t) color << 8;
}

size_t strlen(const char* str)
{
	size_t len = 0;
	while (str[len])
		len++;
	return len;
}

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

size_t terminal_row;
size_t terminal_column;
uint8_t terminal_color;
uint16_t* terminal_buffer;

void terminal_initialize(void)
{
	terminal_row = 0;
	terminal_column = 0;
	terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	terminal_buffer = (uint16_t*) 0xB8000;
	for (size_t y = 0; y < VGA_HEIGHT; y++) {
		for (size_t x = 0; x < VGA_WIDTH; x++) {
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
	}
}

void terminal_setcolor(uint8_t color)
{
	terminal_color = color;
}

void terminal_putentryat(char c, uint8_t color, size_t x, size_t y)
{
	const size_t index = y * VGA_WIDTH + x;
	terminal_buffer[index] = vga_entry(c, color);
}

void terminal_clear_line(size_t y) {
    for (size_t x = 0; x < VGA_WIDTH; x++)
    {
        const size_t index = y * VGA_WIDTH + x;
        terminal_buffer[index] = vga_entry(' ', terminal_color);
    }
    terminal_column = 0;
}

void terminal_clear_current_line() {
    terminal_clear_line(terminal_row);
}

void terminal_shift_rows_up(int amount) {
    for (int n = 0; n < amount; n++) {
        // Index Calc = y * VGA_WIDTH + x
        for (size_t i = 0; i < VGA_HEIGHT * VGA_WIDTH; i += VGA_WIDTH)
        {
            for (size_t j = 0; j < VGA_WIDTH; j++)
            {
                terminal_buffer[i + j] = terminal_buffer[i + j + VGA_WIDTH];
            }
        }

        terminal_clear_line(VGA_HEIGHT - 1);
    }
}

bool terminal_validate_character(char c) {
    switch (c) {
        case '\n':
            return false;
        default:
            return true;
    }
}

void terminal_putchar(char c) {
    if (terminal_validate_character(c))
	    terminal_putentryat(c, terminal_color, terminal_column, terminal_row);
	if (++terminal_column == VGA_WIDTH || c == '\n') {
		terminal_column = 0;
		if (++terminal_row == VGA_HEIGHT) {
			// terminal_row = 0;
            terminal_shift_rows_up(1);
        }
	}
}

void terminal_write(const char* data, size_t size)
{
	for (size_t i = 0; i < size; i++)
		terminal_putchar(data[i]);
}

void terminal_writestring(const char* data)
{
	terminal_write(data, strlen(data));
}

void kernel_main(void)
{
	/* Initialize terminal interface */
	terminal_initialize();
	terminal_writestring("\n\n\n\n\nHello, kernel World!\n");
}