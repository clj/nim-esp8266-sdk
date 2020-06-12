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


when defined userPartitions:
  const userPartitions {.strdefine.} = 0
  {.emit: ["#define USER_PARTITIONS ", userPartitions].}


{.emit: """
#include "user_interface.h"
#include "osapi.h"

#ifndef FOTA
#define EAGLE_FLASH_BIN        (SYSTEM_PARTITION_CUSTOMER_BEGIN + 1)
#define EAGLE_IROM0TEXT_BIN      (SYSTEM_PARTITION_CUSTOMER_BEGIN + 2)
#define USER_DATA_PARTITION_BEGIN        (SYSTEM_PARTITION_CUSTOMER_BEGIN + 3)
#define EAGLE_FLASH_BIN_ADDR        0x00000
#define EAGLE_FLASH_BIN_SIZE        0x10000
#define EAGLE_IROM0TEXT_BIN_ADDR        (EAGLE_FLASH_BIN_ADDR + EAGLE_FLASH_BIN_SIZE)
#define EAGLE_IROM0TEXT_BIN_SIZE        USER_BIN_ALLOCATION
#define SYSTEM_PROGRAM_END        (EAGLE_IROM0TEXT_BIN_ADDR + EAGLE_IROM0TEXT_BIN_SIZE)
#else
#define USER_DATA_PARTITION_BEGIN        (SYSTEM_PARTITION_CUSTOMER_BEGIN)
#define SYSTEM_PROGRAM_END        (SYSTEM_PARTITION_OTA_2_ADDR + USER_BIN_ALLOCATION)
#endif /* FOTA */

#ifndef SPI_FLASH_SIZE_MAP
#define SPI_FLASH_SIZE_MAP 2
#endif

#ifndef USER_BIN_ALLOCATION
#define USER_BIN_ALLOCATION 0x60000
#endif

/*
  size_map     layout                            esptool.py arg
  --------     ------------------------------    --------------
  0              512 KB (256 KB + 256 KB)          512KB
  1              256 KB                            256KB
  2              1024 KB (512 KB + 512 KB)         1MB
  3              2048 KB (512 KB + 512 KB)         2MB
  4              4096 KB (512 KB + 512 KB)         4MB
  5              2048 KB (1024 KB + 1024 KB)       2MB-c1
  6              4096 KB (1024 KB + 1024 KB)       4MB-c1
*/
#if ((SPI_FLASH_SIZE_MAP == 0) || (SPI_FLASH_SIZE_MAP == 1))
#error "The flash map is not supported"
#elif (SPI_FLASH_SIZE_MAP == 2)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x81000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0xfb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0xfc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0xfd000
#elif (SPI_FLASH_SIZE_MAP == 3)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x81000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0x1fb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0x1fc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0x1fd000
#elif (SPI_FLASH_SIZE_MAP == 4)
#define SYSTEM_PARTITION_OTA_1_ADDR            0x01000
#define SYSTEM_PARTITION_OTA_2_ADDR            0x81000
#define SYSTEM_PARTITION_RF_CAL_ADDR            0x3fb000
#define SYSTEM_PARTITION_PHY_DATA_ADDR            0x3fc000
#define SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR        0x3fd000
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
    { EAGLE_FLASH_BIN, EAGLE_FLASH_BIN_ADDR, EAGLE_FLASH_BIN_SIZE},
    { EAGLE_IROM0TEXT_BIN, EAGLE_IROM0TEXT_BIN_ADDR, EAGLE_IROM0TEXT_BIN_SIZE},
#else
    { SYSTEM_PARTITION_OTA_1, SYSTEM_PARTITION_OTA_1_ADDR, USER_BIN_ALLOCATION},
    { SYSTEM_PARTITION_OTA_2, SYSTEM_PARTITION_OTA_2_ADDR, USER_BIN_ALLOCATION},
#endif /* FOTA */
    { SYSTEM_PARTITION_RF_CAL, SYSTEM_PARTITION_RF_CAL_ADDR, 0x1000},
    { SYSTEM_PARTITION_PHY_DATA, SYSTEM_PARTITION_PHY_DATA_ADDR, 0x1000},
    { SYSTEM_PARTITION_SYSTEM_PARAMETER, SYSTEM_PARTITION_SYSTEM_PARAMETER_ADDR, 0x3000},
#ifdef USER_PARTITIONS
    USER_PARTITIONS
#endif /* USER_PARTITIONS */
};

void ICACHE_FLASH_ATTR user_pre_init(void)
{
  if(!system_partition_table_regist(partition_table, sizeof(partition_table)/sizeof(partition_table[0]), SPI_FLASH_SIZE_MAP)) {
    os_printf("system_partition_table_regist fail\r\n");
    while(1);
  }
}
""".}
