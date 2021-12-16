SDK_VERSIONS	?= 3.0.5 3.0.3 2.2.1 2.2.0 2.1.0
CURL		?= curl
SDK_BASE_URL	?= https://github.com/espressif/ESP8266_NONOS_SDK/archive/
BUILD_DIR	?= build
DIST_DIR	?= dist
SRC_DIR		?= src
SDK_SRC_DIR	?= $(SRC_DIR)/nonos-sdk
SHASUM		?= shasum
TAR		?= tar
C2NIM		?= c2nim_esp8266
INSTALL_DIR	?= /opt/nim-esp8266-sdk
ESP_MQTT_URL	?= https://github.com/tuanpmt/esp_mqtt/archive/37cab7cd8a42d51dc9ca448a6eef447ce8ce5b3e.tar.gz

NO_C2NIM_GOALS := clean mostlyclean
ifeq (,$(filter $(NO_C2NIM_GOALS),$(MAKECMDGOALS)))
c2nim_found := $(shell command -v $(C2NIM) 2> /dev/null)
ifndef c2nim_found
$(error $(C2NIM) command not found)
endif
endif

# Set path related variables to have absolute paths
override C2NIM := $(abspath $(C2NIM))

# Pass the absolute paths to recursive makes even if overriden on command line
_PATH_VARS := \
  C2NIM
MAKEOVERRIDES += $(foreach v,$(_PATH_VARS),$(v)=$($(v)))

SHA_256_SUM_2_2_1 = ae218301870ca0d39a939febeccb29cbf75c3f5959d7c521e513bbe8186a2586
SHA_256_SUM_2_2_0 = fe32a54f59004177cf0dafa0e51ae24b948090a847dde6f0383a7776aabbf88a
SHA_256_SUM_2_1_0 = aefafa85ed32688da2e523e6d0affb21c45137408edb298183a92765cee7589f
SHA_256_SUM_3_0_3 = d1b604e3c794d3d1d4fac9d27adfa60db5f7091444ee58a979a328ebf1811f05
SHA_256_SUM_3_0_5 = b126ca033288464aeb0024ebddc45cd9e4543e911f5c47c5fff815552a1eebdb

download_dir = $(BUILD_DIR)/downloads
nonos_sdk_build_dir = $(BUILD_DIR)/nonos-sdk
mqtt_build_dir = $(BUILD_DIR)/mqtt
sdk_archives = $(SDK_VERSIONS:%=$(download_dir)/ESP8266_NONOS_SDK-%.tar.gz)
sdk_archives_shas = $(sdk_archives:%=%.sha_256)
sdk_build_dirs = $(SDK_VERSIONS:%=$(nonos_sdk_build_dir)/%)
libs = mqtt
lib_build_dirs = $(addprefix $(BUILD_DIR)/,$(libs))

esp_mqtt_archive = $(notdir $(ESP_MQTT_URL))
libmqtt = $(BUILD_DIR)/esp_mqtt/firmware/libmqtt.a
libmqtt_user_config = $(BUILD_DIR)/esp_mqtt/include/user_config.local.h
mqtt_install = $(abspath $(libmqtt) $(mqtt_build_dir)/mqtt.h $(addprefix $(BUILD_DIR)/esp_mqtt/mqtt/include/,mqtt_msg.h queue.h ringbuf.h typedef.h))

nim_sdk_files = $(shell find nim/  -type f -name '*.nim')

release_tag = $(shell (git describe --exact-match --tags $$(git log -n1 --pretty='%h') 2>/dev/null || git describe --tags --always) | sed -e "s/release-//")
release_name = nim_esp8266_nonos_sdk-$(release_tag)

mostlyclean_ignore = $(download_dir)

V ?= $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
vechoe := true
else
Q := @
vecho := @echo
vechoe := echo
endif

.PHONY: all dist install install-nim install-dev install-nim-dev install-mqtt install-mqtt-dirs install-mqtt-dev
all: $(sdk_build_dirs) $(lib_build_dirs) $(libmqtt)

dist: $(DIST_DIR)/$(release_name).tar.gz $(DIST_DIR)/$(release_name).zip

install: all |install-nim install-mqtt
	$(vecho) "MKDIR   $(INSTALL_DIR)"
	$(Q) mkdir -p $(INSTALL_DIR)
	$(Q) for version in $(SDK_VERSIONS) ; do \
		$(vechoe) "COPY    $(INSTALL_DIR)/$$version" ; \
		mkdir -p $(INSTALL_DIR)/$$version/esp8266/nonos-sdk && \
		cp -r $(nonos_sdk_build_dir)/$$version/* $(INSTALL_DIR)/$$version/esp8266/nonos-sdk/ ; \
	done

install-nim: $(nim_sdk_files)
	$(vecho) "MKDIR   $(INSTALL_DIR)/nim-sdk"
	$(Q) mkdir -p $(INSTALL_DIR)/nim-sdk/esp8266
	$(Q) for name in $(patsubst nim/%,%,$(nim_sdk_files)) ; do \
		$(vechoe) "COPY    $$name" ; \
		mkdir -p $(INSTALL_DIR)/nim-sdk/esp8266/$$(dirname $$name) && \
		cp nim/$$name $(INSTALL_DIR)/nim-sdk/esp8266/$$name ; \
	done

install-dev: all |install-nim-dev install-mqtt-dev
	$(vecho) "MKDIR   $(INSTALL_DIR)"
	$(Q) mkdir -p $(INSTALL_DIR)
	$(Q) for version in $(SDK_VERSIONS) ; do \
		$(vechoe) "LN      $(INSTALL_DIR)/$$version" ; \
		mkdir -p $(INSTALL_DIR)/$$version/esp8266/ && \
		ln -sf $(abspath  $(nonos_sdk_build_dir)/$$version/) $(INSTALL_DIR)/$$version/esp8266/nonos-sdk ; \
	done

install-nim-dev:
	$(vecho) "MKDIR   $(INSTALL_DIR)/nim-sdk"
	$(Q) mkdir -p $(INSTALL_DIR)/nim-sdk
	$(vecho) "LN      $(INSTALL_DIR)/nim-sdk/esp8266"
	$(Q) ln -sf $(abspath nim) $(INSTALL_DIR)/nim-sdk/esp8266

install-mqtt: fn=cp
install-mqtt: vfn="COPY    "
install-mqtt: install-mqtt-dirs
	$(vecho) $(vfn)"mqtt.nim"
	$(Q) $(fn) $(mqtt_build_dir)/mqtt.nim $(INSTALL_DIR)/libs/esp8266
	$(Q) for name in $(mqtt_install) ; do \
		$(vechoe) $(vfn)"$$(basename $$name)" ; \
		$(fn) $$name $(INSTALL_DIR)/libs/esp8266/mqtt ; \
	done

install-mqtt-dev: fn=ln -sf
install-mqtt-dev: vfn="LN      "
install-mqtt-dev: install-mqtt

install-mqtt-dirs:
	$(vecho) "MKDIR   $(INSTALL_DIR)/libs/esp8266"
	$(Q) mkdir -p $(INSTALL_DIR)/libs/esp8266
	$(vecho) "MKDIR   $(INSTALL_DIR)/libs/esp8266/mqtt"
	$(Q) mkdir -p $(INSTALL_DIR)/libs/esp8266/mqtt

$(DIST_DIR)/$(release_name).tar.gz: INSTALL_DIR=$(DIST_DIR)/nim-esp8266-sdk
$(DIST_DIR)/$(release_name).tar.gz: install
	$(vecho) "TAR     $@"
	$(Q) tar -czf $@ -C $(DIST_DIR) nim-esp8266-sdk

$(DIST_DIR)/$(release_name).zip: INSTALL_DIR=$(DIST_DIR)/nim-esp8266-sdk
$(DIST_DIR)/$(release_name).zip: install
	$(vecho) "ZIP     $@"
	$(Q) cd $(DIST_DIR) && zip -qr $(@F) nim-esp8266-sdk

.PHONY: $(sdk_build_dirs)
$(sdk_build_dirs):
	$(vecho) "BUILD   NONOS-SDK-$(sdk_version)"
	$(Q) $(MAKE) --directory=src/nonos-sdk/$(src_version_dir) SDK_DIR=$(sdk_dir)

.PHONY: $(lib_build_dirs)
$(lib_build_dirs):
	$(vecho) "BUILD   $@"
	$(Q) $(MAKE) --directory=src/$(notdir $@)

$(download_dir)/ESP8266_NONOS_SDK-%.tar.gz:
	$(vecho) "CURL    $(SDK_BASE_URL)v$*.tar.gz"
	$(Q) $(CURL) --silent $(SDK_BASE_URL)v$*.tar.gz -L -o $@

$(download_dir)/ESP8266_NONOS_SDK-%.tar.gz.sha_256:
	$(vecho) "GEN     $@"
	@echo "$(SHA_256_SUM_$(subst .,_,$*))  ESP8266_NONOS_SDK-$*.tar.gz" > $@

$(download_dir)/ESP8266_NONOS_SDK-%: $(download_dir)/ESP8266_NONOS_SDK-%.tar.gz $(download_dir)/ESP8266_NONOS_SDK-%.tar.gz.sha_256
	$(vecho) "SHA256  $<"
	$(Q) cd $(download_dir) && $(SHASUM) --status -c $(<F).sha_256
	$(vecho) "TAR     $<"
	$(Q) cd $(download_dir) && $(TAR) -xf $(<F) && touch $(@F)

$(download_dir)/$(esp_mqtt_archive): | $(download_dir)
	$(vecho) "CURL    $(ESP_MQTT_URL)"
	$(Q) $(CURL) --silent $(ESP_MQTT_URL) -L -o $@

$(BUILD_DIR)/esp_mqtt: $(download_dir)/$(esp_mqtt_archive) | $(BUILD_DIR)
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $@
	$(vecho) "TAR     $<"
	$(Q) $(TAR) --strip-components=1 -C $@ -xf $< && touch -r $< $@ || rm -rf $@

$(download_dir):
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(download_dir)

$(BUILD_DIR):
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(BUILD_DIR)

$(sdk_archives): | $(download_dir)

$(nonos_sdk_build_dir)/2.2.1: src_version_dir=2.x
$(nonos_sdk_build_dir)/2.2.0: src_version_dir=2.x
$(nonos_sdk_build_dir)/2.1.0: src_version_dir=2.x
$(nonos_sdk_build_dir)/3.0.3: src_version_dir=3.x
$(nonos_sdk_build_dir)/3.0.5: src_version_dir=3.x

$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): | $(download_dir)/ESP8266_NONOS_SDK-$(version)))
$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): sdk_dir=$(abspath $(download_dir)/ESP8266_NONOS_SDK-$(version))))
$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): sdk_version=$(version)))

export MQTT_DIR=$(abspath $(BUILD_DIR)/esp_mqtt/mqtt)
$(BUILD_DIR)/mqtt: $(BUILD_DIR)/esp_mqtt

define MQTT_USER_CONFIG
#define PROTOCOL_NAMEv311
#define MQTT_BUF_SIZE   1024
#define MQTT_RECONNECT_TIMEOUT  5 /*second*/
endef
export MQTT_USER_CONFIG

$(libmqtt_user_config):
	echo "$$MQTT_USER_CONFIG" >> $@

$(libmqtt): $(libmqtt_user_config)
	$(vecho) "BUILD   $@"
	$(Q) $(MAKE) --directory=$(BUILD_DIR)/esp_mqtt VERBOSE=$(if $(filter $(if $(strip $(VERBOSE)),$(VERBOSE),0),0),no,yes) SDK_BASE=$(abspath $(download_dir)/ESP8266_NONOS_SDK-2.2.1) checkdirs firmware/libmqtt.a

.PHONY: clean mostlyclean
clean:
	$(vecho) "CLEAN   $(BUILD_DIR) $(DIST_DIR)"
	$(Q) rm -rf $(BUILD_DIR) $(DIST_DIR)

mostlyclean: dirs := $(filter-out $(mostlyclean_ignore),$(wildcard $(BUILD_DIR)/*))
mostlyclean:
	$(vecho) "CLEAN   $(dirs)"
	$(Q) rm -rf $(dirs)
