# See:
# * https://github.com/espressif/ESP8266_NONOS_SDK/blob/199848519137b8ba12209f1078350282941382bd/include/user_interface.h#L142-L154
# * https://github.com/espressif/ESP8266_NONOS_SDK/blob/master/documents/EN/%20Partition%20Table.md

{.used.}

when defined fota:
  {.emit: """
  #define FOTA
  """.}


when defined spiFlashSizeMap:
  const spiFlashSizeMap {.strdefine.} = 0
  {.emit: ["#define SPI_FLASH_SIZE_MAP ", spiFlashSizeMap].}


when defined userBinAllocation:
  const userBinAllocation {.strdefine.} = 0
  {.emit: ["#define USER_BIN_ALLOCATION ", userBinAllocation].}


{.emit: """
#include "user_interface.h"
#include "osapi.h"

#define EAGLE_FLASH_BIN_ADDR        (SYSTEM_PARTITION_CUSTOMER_BEGIN + 1)
#define EAGLE_IROM0TEXT_BIN_ADDR      (SYSTEM_PARTITION_CUSTOMER_BEGIN + 2)

#ifndef SPI_FLASH_SIZE_MAP
#define SPI_FLASH_SIZE_MAP 5
#endif

#ifndef USER_BIN_ALLOCATION
#define USER_BIN_ALLOCATION 0x60000
#endif

#if ((SPI_FLASH_SIZE_MAP == 0) || (SPI_FLASH_SIZE_MAP == 1) || \
     (SPI_FLASH_SIZE_MAP == 3) || (SPI_FLASH_SIZE_MAP == 4))
#error "The flash map is not supported"
#elif (SPI_FLASH_SIZE_MAP == 2)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x81000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0xfb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0xfc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0xfd000
#elif (SPI_FLASH_SIZE_MAP == 5)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x101000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0x1fb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0x1fc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0x1fd000
#elif (SPI_FLASH_SIZE_MAP == 6)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x101000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0x3fb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0x3fc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0x3fd000
#else
#error "The flash map is not supported"
#endif

static const partition_item_t partition_table[] = {
#ifndef FOTA
    { EAGLE_FLASH_BIN_ADDR,   0x00000, 0x10000},
    { EAGLE_IROM0TEXT_BIN_ADDR, 0x10000, USER_BIN_ALLOCATION},
#else
    { SYSTEM_PARTITION_OTA_1, SYSTEM_PARTITION_OTA_1_ADDR, USER_BIN_ALLOCATION},
    { SYSTEM_PARTITION_OTA_2, SYSTEM_PARTITION_OTA_2_ADDR, USER_BIN_ALLOCATION},
#endif /* FOTA */
    { SYSTEM_PARTITION_RF_CAL, SYSTEM_PARTITION_RF_CAL_ADDR, 0x1000},
    { SYSTEM_PARTITION_PHY_DATA, SYSTEM_PARTITION_PHY_DATA_ADDR, 0x1000},
    { SYSTEM_PARTITION_SYSTEM_PARAMETER, SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR, 0x3000},
};

void ICACHE_FLASH_ATTR user_pre_init(void)
{
  if(!system_partition_table_regist(partition_table, sizeof(partition_table)/sizeof(partition_table[0]), SPI_FLASH_SIZE_MAP)) {
    os_printf("system_partition_table_regist fail\r\n");
    while(1);
  }
}
""".}
