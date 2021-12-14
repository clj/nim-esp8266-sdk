# nim-esp8266-sdk

[![Build Status](https://travis-ci.org/clj/nim-esp8266-sdk.svg?branch=master)](https://travis-ci.org/clj/nim-esp8266-sdk)

A Nim wrapper for the [ESP8266 NON-OS SDKs](https://github.com/espressif/ESP8266_NONOS_SDK)

## Supported SDK versions

Currently the following SDK versions are supported:

* 2.1.0
* 2.2.0
* 2.2.1
* 3.0.3
* 3.0.5

## Installing

Download pre-built Nim ESP8266 SDK releases from https://github.com/clj/nim-esp8266-sdk/releases.

## Examples

Examples can be found at: https://github.com/clj/nim-esp8266-examples

## Building

* `make C2NIM=...`
* `make install` or `make install INSTALL_DIR=...`

C2NIM should point to a built copy of [c2nim esp8266](https://github.com/clj/c2nim-esp8266) and defaults to c2nim_esp8266. The default installation directory is `/opt/nim-esp8266-sdk`.

### Dependencies

* [c2nim_esp8266](https://github.com/clj/c2nim-esp8266)
* [ESP8266 NON-OS SDKs](https://github.com/espressif/ESP8266_NONOS_SDK)
  - Downloaded automatically by the Makefile
* [tuanpmt/esp_mqtt](https://github.com/tuanpmt/esp_mqtt)
  - Downloaded automatically by the Makefile
  - `ESP_MQTT_URL` can be
  - The project has not been updated in a while so please check the [issue tracker](https://github.com/tuanpmt/esp_mqtt/issues) if you encounter problems

## License

The files in this repository are licensed under the MIT license, see the LICENSE file.