
#ifndef _STRING_H_
#define _STRING_H_

#include <stddef.h>

namespace nstd {
    [[maybe_unused]] static size_t strlen(const char *str)
    {
		size_t len = 0;
		while (str[len])
			len++;
		return len;
	}
}

#endif