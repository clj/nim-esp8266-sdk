import esp8266/nonos-sdk/osapi
import esp8266/nonos-sdk/user_interface


proc printResetReason*(always: bool = false) =
  let rstInfo = system_get_rst_info()
  if always:
    os_printf("Reset reason: %x\n", rstInfo.reason)
  if (rstInfo.reason == uint32(REASON_WDT_RST) or
      rstInfo.reason == uint32(REASON_EXCEPTION_RST) or
      rstInfo.reason == uint32(REASON_SOFT_WDT_RST)):
    if not always:
      os_printf("Reset reason: %x\n", rstInfo.reason)
    if rstInfo.reason == uint32(REASON_EXCEPTION_RST):
      os_printf("Fatal exception (%d):\n", rstInfo.exccause)
    os_printf(
      "epc1=0x%08x, epc2=0x%08x, epc3=0x%08x, excvaddr=0x%08x, depc=0x%08x\n",
      rstInfo.epc1, rstInfo.epc2, rstInfo.epc3, rstInfo.excvaddr,
      rstInfo.depc)
