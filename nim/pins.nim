## A (slightly) higher level GPIO library for the ESP8266

import esp8266/nonos-sdk/gpio

type
    pin_value* = range[0..1]


## Invert a pin_value
template `not`*(v: pin_value): untyped =
  pin_value((int(v) xor 1))


## Set a gpio output pin high or low
template pin_set*(pin: int, value: pin_value) =
  gpio_output_set(uint32((not pin_value(value)) shl pin), uint32(value shl pin),
                  uint32(1 shl pin), 0)


## Set a gpio output pin high or open drain
template pin_set_open_drain*(pin: int, value: pin_value) =
    gpio_output_set(0, uint32((not pin_value(value)) shl pin),
                    uint32((not value) shl pin), uint32(value shl pin))


## Read the state of a gpio output pin
template get_pin_state*(pin: int): untyped =
    pin_value((GPIO_REG_READ(GPIO_OUT_ADDRESS) and uint32(1 shl pin)) shr pin)


## Read the value on a gpio input pin
template pin_get*(pin: int): untyped =
    pin_value(GPIO_INPUT_GET(cuint(pin)))
