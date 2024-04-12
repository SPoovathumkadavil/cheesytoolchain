
#include "system/terminal.h"

static const size_t VGA_WIDTH = 80;
static const size_t VGA_HEIGHT = 25;

static size_t row;
static size_t column;
static uint8_t color;
static uint16_t *buffer;

void terminal::initialize(void)
{
    row = 0;
    column = 0;
    color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
    buffer = (uint16_t *)0xB8000;
    for (size_t y = 0; y < VGA_HEIGHT; y++)
    {
        for (size_t x = 0; x < VGA_WIDTH; x++)
        {
            const size_t index = y * VGA_WIDTH + x;
            buffer[index] = vga_entry(' ', color);
        }
    }
}

void terminal::setcolor(uint8_t color)
{
    color = color;
}

void terminal::putentryat(char c, uint8_t color, size_t x, size_t y)
{
    const size_t index = y * VGA_WIDTH + x;
    buffer[index] = vga_entry(c, color);
}

void terminal::clear_line(size_t y)
{
    for (size_t x = 0; x < VGA_WIDTH; x++)
    {
        const size_t index = y * VGA_WIDTH + x;
        buffer[index] = vga_entry(' ', color);
    }
    column = 0;
}

void terminal::clear_current_line()
{
    clear_line(row);
}

void terminal::shift_rows_up(int amount)
{
    for (int n = 0; n < amount; n++)
    {
        // Index Calc = y * VGA_WIDTH + x
        for (size_t i = 0; i < VGA_HEIGHT * VGA_WIDTH; i += VGA_WIDTH)
        {
            for (size_t j = 0; j < VGA_WIDTH; j++)
            {
                buffer[i + j] = buffer[i + j + VGA_WIDTH];
            }
        }

        clear_line(VGA_HEIGHT - 1);
    }
}

bool terminal::validate_character(char c)
{
    switch (c)
    {
    case '\n':
        return false;
    default:
        return true;
    }
}

void terminal::putchar(char c)
{
    if (validate_character(c))
        putentryat(c, color, column, row);
    if (++column == VGA_WIDTH || c == '\n')
    {
        column = 0;
        if (++row == VGA_HEIGHT)
        {
            shift_rows_up(1);
        }
    }
}

void terminal::write(const char *data, size_t size)
{
    for (size_t i = 0; i < size; i++)
        putchar(data[i]);
}

void terminal::write_string(const char *data)
{
    write(data, strlen(data));
}
