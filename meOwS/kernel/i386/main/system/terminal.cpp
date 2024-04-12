
#include "system/terminal.h"

namespace system
{

	size_t terminal::terminal_row = 0;
	size_t terminal::terminal_column = 0;
	uint8_t terminal::terminal_color = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
	uint16_t *terminal::terminal_buffer = (uint16_t *)0xB8000;

	size_t terminal::buflen(const uint16_t *buf)
	{
		size_t len = 0;
		while (buf[len])
			len++;
		return len;
	}

	void terminal::initialize(void)
	{
		for (size_t y = 0; y < VGA_HEIGHT; y++)
		{
			for (size_t x = 0; x < VGA_WIDTH; x++)
			{
				const size_t index = y * VGA_WIDTH + x;
				terminal_buffer[index] = vga_entry(' ', terminal_color);
			}
		}
	}

	void terminal::set_color(uint8_t color)
	{
		terminal_color = color;
	}

	void terminal::put_entryat(char c, uint8_t color, size_t x, size_t y)
	{
		const size_t index = y * VGA_WIDTH + x;
		terminal_buffer[index] = vga_entry(c, color);
	}

	void terminal::clear_line(size_t y)
	{
		for (size_t x = 0; x < VGA_WIDTH; x++)
		{
			const size_t index = y * VGA_WIDTH + x;
			terminal_buffer[index] = vga_entry(' ', terminal_color);
		}
		terminal_column = 0;
	}

	void terminal::clear_currentline()
	{
		clear_line(terminal_row);
	}

	void terminal::clear_buffer()
	{
		for (size_t y = 0; y < VGA_HEIGHT; y++)
		{
			clear_line(y);
		}
	}

	void terminal::shift_rowsup()
	{
		// Index Calc = y * VGA_WIDTH + x
		for (size_t i = 0; i < VGA_HEIGHT * VGA_WIDTH; i += VGA_WIDTH)
		{
			for (size_t j = 0; j < VGA_WIDTH; j++)
			{
				terminal_buffer[i + j] = terminal_buffer[i + j + VGA_WIDTH];
			}
		}

		clear_line(VGA_HEIGHT - 1);
	}

	void terminal::put_char(char c)
	{
		// First Increment and do checks
		if (terminal_column == VGA_WIDTH)
		{
			terminal_column = 0;
			terminal_row++;
		}
		else if (c == '\n')
		{
			terminal_column = 0; // FIXME!!!
			terminal_row++;
			return;
		}

		if (terminal_row == VGA_HEIGHT)
		{
			shift_rowsup();
			terminal_row--;
		}

		// Then Put Entry
		put_entryat(c, terminal_color, terminal_column, terminal_row);

		terminal_column++;
	}

	void terminal::write(const char *data, size_t size)
	{
		for (size_t i = 0; i < size; i++)
			put_char(data[i]);
	}

	void terminal::write_string(const char *data)
	{
		write(data, nstd::strlen(data));
	}

	void terminal::write_centeredstring(const char *data)
	{
		size_t len = nstd::strlen(data);
		if (len > VGA_WIDTH - 1)
			return;
		size_t offset = (size_t)((VGA_WIDTH / 2) - (len / 2));
		for (size_t i = 0; i < offset; i++)
			put_char(' ');
		for (size_t i = 0; i < len; i++)
			put_char(data[i]);
	}

	void terminal::print_splash()
	{
		clear_buffer();
		set_color(VGA_COLOR_LIGHT_RED);
		terminal_row = VGA_HEIGHT / 2 - 2;
		write_centeredstring((char *)"                 ___            ____  \n");
		write_centeredstring((char *)" _ __ ___   ___ / _ \\__      __/ ___| \n");
		write_centeredstring((char *)"| '_ ` _ \\ / _ \\ | | \\ \\ /\\ / /\\___ \\ \n");
		write_centeredstring((char *)" | | | | | |  __/ |_| |\\ V  V /  ___) | \n");
		write_centeredstring((char *)"|_| |_| |_|\\___|\\___/  \\_/\\_/  |____/ \n");
		set_color(VGA_COLOR_LIGHT_GREY);
	}

} // namespace nstd