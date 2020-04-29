# This is required to be able to link using a non standalone (STANDALONE=n)
# esp-open-sdk and non-patched Espressif ESP8266_NONOS_SDKs

# Source: https://github.com/pfalcon/esp-open-sdk/blob/e629109c762b505839cb2a06763f8615447e6e67/user_rf_cal_sector_set.c
# License: https://github.com/pfalcon/esp-open-sdk/tree/e629109c762b505839cb2a06763f8615447e6e67#license
{.used.}

{.emit: """
#include <c_types.h>
#include <spi_flash.h>

uint32 user_rf_cal_sector_set(void) {
    extern char flashchip;
    SpiFlashChip *flash = (SpiFlashChip*)(&flashchip + 4);
    // We know that sector size in 4096
    //uint32_t sec_num = flash->chip_size / flash->sector_size;
    uint32_t sec_num = flash->chip_size >> 12;
    return sec_num - 5;
}
""".}