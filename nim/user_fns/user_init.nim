{.used.}

{.emit: """
#include "user_interface.h"

void ICACHE_FLASH_ATTR
user_init()
{
    NimMain();
    nim_user_init();
}
""".}
