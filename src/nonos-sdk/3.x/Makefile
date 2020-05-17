C2NIM ?= c2nim_esp8266
SDK_VERSION ?= $(shell echo "$(SDK_DIR)" | awk -F"-" '{ print $$NF }')
SDK_VERSION_ = $(subst /,,$(subst .,_,$(SDK_VERSION)))
BUILD_DIR ?= ../../../build/nonos-sdk/$(SDK_VERSION)
SHELL = /usr/bin/env bash

ifndef SDK_DIR
$(error SDK_DIR is not set)
endif

ifneq ($(findstring README.md,$(wildcard $(SDK_DIR)/*)),README.md)
$(error This doesn't look like an ESP8266 NON-OS SDK dir)
else
ifneq ($(findstring ESP8266_NONOS_SDK,$(shell cat $(SDK_DIR)/README.md)),ESP8266_NONOS_SDK)
$(error This doesn't look like an ESP8266 NON-OS SDK dir)
endif
endif

headers = c_types.h eagle_soc.h espconn.h ets_sys.h gpio.h ip_addr.h \
		  mem.h os_type.h osapi.h queue.h upgrade.h user_interface.h
linker_scripts = eagle.app.v6.ld eagle.app.v6.new.1024.app1.ld eagle.app.v6.new.1024.app2.ld eagle.app.v6.new.2048.ld eagle.rom.addr.v6.ld
sdk_sources = $(headers:%=$(SDK_DIR)/%)
sdk_targets = $(headers:%=$(BUILD_DIR)/%)
nim_targets = $(headers:%.h=$(BUILD_DIR)/%.nim)
ld_targets = $(linker_scripts:%=$(BUILD_DIR)/ld/%)

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
all: $(nim_targets) $(ld_targets) $(BUILD_DIR)/bin/check_sdk_version.sh

$(BUILD_DIR)/%.h: $(SDK_DIR)/include/%.h %.h.$(SDK_VERSION_).patch
	$(vecho) "PATCH   $@"

	$(Q) $(call patch_cmd)

$(BUILD_DIR)/%.h: $(SDK_DIR)/include/%.h %.h.patch
	$(vecho) "PATCH   $@"
	$(Q) $(call patch_cmd)

$(BUILD_DIR)/%.h: $(SDK_DIR)/include/%.h
	$(vecho) "CP      $@"
	$(Q) cp $< $@

$(BUILD_DIR)/%.nim: %.c2nim $(BUILD_DIR)/%.h
	$(vecho) "C2NIM   $@"
	$(Q) $(C2NIM) --cdecl --header $^ -o=$@ $(silence)

$(BUILD_DIR)/%.nim: $(BUILD_DIR)/%.h
	$(vecho) "C2NIM   $@"
	$(Q) $(C2NIM) --cdecl --header $< -o=$@ $(silence)

$(BUILD_DIR)/ld/%.ld: $(SDK_DIR)/ld/%.ld %.ld.patch
	$(vecho) "PATCH   $@"
	$(Q) $(call patch_cmd)

$(BUILD_DIR)/ld/%.ld: $(SDK_DIR)/ld/%.ld
	$(vecho) "CP      $@"
	$(Q) cp $< $@

$(BUILD_DIR)/bin/check_sdk_version.sh: ../../tools/check_sdk_version.sh.in $(SDK_DIR)/VERSION
	sed "s/_SHA_/$(shell sha1sum $(SDK_DIR)/VERSION | awk '{ print $$1 }')/;s/_VERSION_/$(SDK_VERSION)/" $< > $@
	chmod a+x $@

$(sdk_targets): | $(BUILD_DIR)
$(nim_targets): | $(BUILD_DIR)
$(nim_targets): | $(BUILD_DIR)/ld
$(BUILD_DIR)/bin/check_sdk_version.sh: | $(BUILD_DIR)/bin

$(BUILD_DIR):
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/ld:
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(BUILD_DIR)/ld

$(BUILD_DIR)/bin:
	$(vecho) "MKDIR   $@"
	$(Q) mkdir -p $(BUILD_DIR)/bin

.PHONY: clean
clean:
	$(vecho) "CLEAN   $(BUILD_DIR)"
	$(Q) rm -rf $(BUILD_DIR)


.PHONY: patches
patches:
	@for header in $(headers) ; do \
		if [ -e "$$header.$(SDK_VERSION_).patch" ]; then \
			patch_name="$$header.$(SDK_VERSION_).patch" ; \
		else \
			patch_name="$$header.patch" ; \
		fi ; \
		diff -uN $(SDK_DIR)/include/$$header $(BUILD_DIR)/$$header | \
		sed -e 's!$(SDK_DIR)!SDK!' -e 's!$(BUILD_DIR)!BUILD!' > $$patch_name.tmp ; \
		if [ ! -s "$$patch_name.tmp"  ]; then \
			rm -f "$$patch_name" && echo "Empty patch: $$patch_name" ; \
		elif [ ! -e "$$patch_name" ] || ! diff -q <(tail -n +3 $$patch_name) <(tail -n +3 $$patch_name.tmp) >/dev/null; then \
			cp "$$patch_name.tmp" "$$patch_name" && echo "Updated: $$patch_name" ; \
		else \
			echo "No changes: $$patch_name" ; \
		fi ; \
		rm -f "$$patch_name.tmp" ; \
	done
