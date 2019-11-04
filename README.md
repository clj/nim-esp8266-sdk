# nim-esp8266-sdk

[![Build Status](https://travis-ci.org/clj/nim-esp8266-sdk.svg?branch=master)](https://travis-ci.org/clj/nim-esp8266-sdk)

A Nim wrapper for the [ESP8266 NON-OS SDKs](https://github.com/espressif/ESP8266_NONOS_SDK)

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

## License

The files in this repository are licensed under the MIT license, see the LICENSE file.