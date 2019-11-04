SDK_VERSIONS	?= 2.2.1 2.2.0 2.1.0
CURL		?= curl
SDK_BASE_URL	?= https://github.com/espressif/ESP8266_NONOS_SDK/archive/
BUILD_DIR	?= build
DIST_DIR	?= dist
SRC_DIR		?= src/nonos-sdk
SHASUM		?= shasum
TAR		?= tar
C2NIM		?= c2nim_esp8266
INSTALL_DIR     ?= /opt/nim-esp8266-sdk

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

download_dir = $(BUILD_DIR)/downloads
nonos_sdk_build_dir = $(BUILD_DIR)/nonos-sdk
sdk_archives = $(SDK_VERSIONS:%=$(download_dir)/ESP8266_NONOS_SDK-%.tar.gz)
sdk_archives_shas = $(sdk_archives:%=%.sha_256)
sdk_build_dirs = $(SDK_VERSIONS:%=$(nonos_sdk_build_dir)/%)

nim_sdk_files = $(wildcard nim/*.nim)

release_tag = $(shell (git describe --exact-match --tags $$(git log -n1 --pretty='%h') 2>/dev/null || git describe --tags) | sed -e "s/release-//")
release_name = nim_esp8266_nonos_sdk-$(release_tag)
sdk_latest = $(word 1,$(SDK_VERSIONS))

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

.PHONY: all dist install install-nim
all: $(sdk_build_dirs)

dist: $(DIST_DIR)/$(release_name).tar.gz $(DIST_DIR)/$(release_name).zip

install: $(foreach version,$(SDK_VERSIONS),$(nonos_sdk_build_dir)/$(version)) |install-nim install-link-latest
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
	$(vecho) "COPY    $(INSTALL_DIR)/nim-sdk"
	$(Q) cp -r $^ $(INSTALL_DIR)/nim-sdk/esp8266

install-link-latest:
	$(vecho) "LN      $(INSTALL_DIR)/latest -> $(sdk_latest)"
	$(Q) ln -sf $(sdk_latest) $(INSTALL_DIR)/latest

install-dev: $(foreach version,$(SDK_VERSIONS),$(nonos_sdk_build_dir)/$(version)) |install-nim-dev install-link-latest
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

$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): | $(download_dir)/ESP8266_NONOS_SDK-$(version)))
$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): sdk_dir=$(abspath $(download_dir)/ESP8266_NONOS_SDK-$(version))))
$(foreach version,$(SDK_VERSIONS),$(eval $(nonos_sdk_build_dir)/$(version): sdk_version=$(version)))

.PHONY: clean mostlyclean
clean:
	$(vecho) "CLEAN   $(BUILD_DIR) $(DIST_DIR)"
	$(Q) rm -rf $(BUILD_DIR) $(DIST_DIR)

mostlyclean:
	$(vecho) "CLEAN   $(BUILD_DIR)/nonos-sdk"
	$(Q) rm -rf $(BUILD_DIR)/nonos-sdk
