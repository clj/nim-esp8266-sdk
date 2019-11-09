C2NIM ?= c2nim_esp8266
BUILD_DIR ?= ../../build/mqtt/
SHELL = /usr/bin/env bash

ifndef MQTT_DIR
$(error MQTT_DIR is not set)
endif

ifneq ($(findstring mqtt.h,$(wildcard $(MQTT_DIR)/include/*)),mqtt.h)
$(error $(MQTT_DIR) doesn't look like a ESP_MQTT dir)
endif

headers = mqtt.h
sdk_sources = $(headers:%=$(MQTT_DIR)/%)
sdk_targets = $(headers:%=$(BUILD_DIR)/%)
nim_targets = $(headers:%.h=$(BUILD_DIR)/%.nim)

# XXX: the `cat` here is necessary on my virtualbox setup, or the start
#      of the file goes missing...
patch_version = $(shell patch --version | head -n 1 | awk '{ print $$NF }')
ifeq "$(firstword $(sort $(patch_version) 2.7.2))" "$(patch_version)"
	patch_cmd = patch --quiet -r $@.rej -o /dev/stdout $(abspath $<) < $(word 2,$^) | cat > $@
else
	patch_cmd = patch --quiet -r $@.rej -o - $(abspath $<) < $(word 2,$^) | cat > $@
endif

V ?= $(VERBOSE)
ifeq ("$(V)","1")
Q :=
vecho := @true
silence :=
else
Q := @
vecho := @echo
silence := > /dev/null 2>&1
endif

.SECONDARY: $(sdk_targets)

.PHONY: all
all: $(nim_targets)

$(BUILD_DIR)/%.h: $(MQTT_DIR)/include/%.h %.h.$(SDK_VERSION_).patch
	$(vecho) "PATCH   $@"

	$(Q) $(call patch_cmd)

$(BUILD_DIR)/%.h: $(MQTT_DIR)/include/%.h %.h.patch
	$(vecho) "PATCH   $@"
	$(Q) $(call patch_cmd)

$(BUILD_DIR)/%.h: $(MQTT_DIR)/include/%.h
	$(vecho) "CP      $@"
	$(Q) cp $< $@

$(BUILD_DIR)/%.nim: %.c2nim $(BUILD_DIR)/%.h
	$(vecho) "C2NIM   $@"
	$(Q) $(C2NIM) --cdecl --header $^ -o=$@ $(silence)

$(BUILD_DIR)/%.nim: $(BUILD_DIR)/%.h
	$(vecho) "C2NIM   $@"
	$(Q) $(C2NIM) --cdecl --header $< -o=$@ $(silence)

$(sdk_targets): | $(BUILD_DIR)
$(nim_targets): | $(BUILD_DIR)

$(BUILD_DIR):
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(BUILD_DIR)


.PHONY: clean
clean:
	$(vecho) "CLEAN   $(BUILD_DIR)"
	$(Q) rm -rf $(BUILD_DIR)
