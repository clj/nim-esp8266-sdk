FROM ghcr.io/clj/esp8266-gcc:latest AS esp8266-nim-sdk

ARG NIM_ESP_SDK_VERSION
ARG ESP_SDK_VERSION=3.0.5

WORKDIR /opt

RUN curl -L https://github.com/clj/nim-esp8266-sdk/releases/download/release-$NIM_ESP_SDK_VERSION/nim_esp8266_nonos_sdk-$NIM_ESP_SDK_VERSION.tar.gz | tar -xz && \
    curl -L https://github.com/espressif/ESP8266_NONOS_SDK/archive/v$ESP_SDK_VERSION.zip > v$ESP_SDK_VERSION.zip && unzip v$ESP_SDK_VERSION.zip && rm v$ESP_SDK_VERSION.zip

ENV SDK_BASE="/opt/ESP8266_NONOS_SDK-$ESP_SDK_VERSION"
ENV NIM_SDK_BASE="/opt/nim-esp8266-sdk/$ESP_SDK_VERSION"
