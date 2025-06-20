#
# Copyright (C) 2011 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include device/google/gs-common/device.mk
include device/google/gs-common/gs_watchdogd/watchdog.mk
include device/google/gs-common/ramdump_and_coredump/ramdump_and_coredump.mk
include device/google/gs-common/soc/soc.mk
include device/google/gs-common/soc/freq.mk
include device/google/gs-common/modem/modem.mk
include device/google/gs-common/aoc/aoc.mk
include device/google/gs-common/thermal/dump/thermal.mk
include device/google/gs-common/thermal/thermal_hal/device.mk
include device/google/gs-common/pixel_metrics/pixel_metrics.mk
include device/google/gs-common/performance/perf.mk
include device/google/gs-common/power/power.mk
include device/google/gs-common/display/dump.mk
include device/google/gs101/dumpstate/item.mk
include device/google/gs-common/radio/dump.mk
include device/google/gs-common/gear/dumpstate/aidl.mk
include device/google/gs-common/camera/dump.mk
include device/google/gs-common/gps/dump/log.mk
include device/google/gs-common/widevine/widevine.mk
include device/google/gs-common/sota_app/factoryota.mk
include device/google/gs-common/misc_writer/misc_writer.mk
include device/google/gs-common/gyotaku_app/gyotaku.mk
include device/google/gs-common/bootctrl/bootctrl_aidl.mk
include device/google/gs-common/betterbug/betterbug.mk
ifneq ($(filter oriole raven bluejay, $(TARGET_PRODUCT)),)
  include device/google/gs-common/bcmbt/dump/dumplog.mk
endif
include device/google/gs-common/fingerprint/fingerprint.mk

TARGET_BOARD_PLATFORM := gs101
DEVICE_IS_64BIT_ONLY ?= $(if $(filter %_64,$(TARGET_PRODUCT)),true,false)

ifeq ($(DEVICE_IS_64BIT_ONLY),true)
LOCAL_64ONLY := _64
endif

AB_OTA_POSTINSTALL_CONFIG += \
	RUN_POSTINSTALL_system=true \
	POSTINSTALL_PATH_system=system/bin/otapreopt_script \
	FILESYSTEM_TYPE_system=ext4 \
POSTINSTALL_OPTIONAL_system=true

# Set Vendor SPL to match platform
VENDOR_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)

# Set boot SPL
BOOT_SECURITY_PATCH = $(PLATFORM_SECURITY_PATCH)

PRODUCT_SOONG_NAMESPACES += \
	hardware/google/av \
	hardware/google/interfaces \
	hardware/google/pixel \
	device/google/gs101

LOCAL_KERNEL := $(TARGET_KERNEL_DIR)/Image.lz4

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
#Set IKE logs to verbose for WFC
PRODUCT_PROPERTY_OVERRIDES += log.tag.IKE=VERBOSE

#Set Shannon IMS logs to debug
PRODUCT_PROPERTY_OVERRIDES += log.tag.SHANNON_IMS=DEBUG

#Set Shannon QNS logs to debug
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS=DEBUG
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS-ims=DEBUG
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS-emergency=DEBUG
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS-mms=DEBUG
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS-xcap=DEBUG
PRODUCT_PROPERTY_OVERRIDES += log.tag.ShannonQNS-HC=DEBUG

# Modem userdebug
include device/google/gs101/modem/userdebug.mk
endif

include device/google/gs101/modem/user.mk

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
# b/36703476: Set default log size to 1M
PRODUCT_PROPERTY_OVERRIDES += \
	ro.logd.size=1M
# b/114766334: persist all logs by default rotating on 30 files of 1MiB
PRODUCT_PROPERTY_OVERRIDES += \
	logd.logpersistd=logcatd \
	logd.logpersistd.size=30
endif

USE_LASSEN_OEMHOOK := true
# The "power-anomaly-sitril" is added into PRODUCT_SOONG_NAMESPACES when
# $(USE_LASSEN_OEMHOOK) is true and $(BOARD_WITHOUT_RADIO) is not true.
ifneq ($(BOARD_WITHOUT_RADIO),true)
    $(call soong_config_set,sitril,use_lassen_oemhook_with_radio,true)
endif

# Use for GRIL
USES_LASSEN_MODEM := true
$(call soong_config_set, vendor_ril_google_feature, use_lassen_modem, true)

ifeq ($(USES_GOOGLE_DIALER_CARRIER_SETTINGS),true)
USE_GOOGLE_DIALER := true
USE_GOOGLE_CARRIER_SETTINGS := true
endif

# Audio client implementation for RIL
USES_GAUDIO := true

# ######################
# GRAPHICS - GPU (begin)

# Must match BOARD_USES_SWIFTSHADER in BoardConfig.mk
USE_SWIFTSHADER := false

# HWUI
TARGET_USES_VULKAN = true

# Used in gfx_tools when defining tests with composer2 interface for gs101 devices
$(call soong_config_set,gfx_tools,use_hwc2,true)

include device/google/gs-common/gpu/gpu.mk

# Install the OpenCL ICD Loader
PRODUCT_SOONG_NAMESPACES += external/OpenCL-ICD-Loader
PRODUCT_PACKAGES += \
       libOpenCL

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.opengles.aep.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.opengles.aep.xml \
	frameworks/native/data/etc/android.hardware.vulkan.version-1_3.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.version.xml \
	frameworks/native/data/etc/android.hardware.vulkan.level-1.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.level.xml \
	frameworks/native/data/etc/android.hardware.vulkan.compute-0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.vulkan.compute.xml \
	frameworks/native/data/etc/android.software.vulkan.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.vulkan.deqp.level.xml \
	frameworks/native/data/etc/android.software.opengles.deqp.level-2024-03-01.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.opengles.deqp.level.xml

# GRAPHICS - GPU (end)
# ####################

# Device Manifest, Device Compatibility Matrix for Treble
DEVICE_MANIFEST_FILE := \
	device/google/gs101/manifest$(LOCAL_64ONLY).xml

BOARD_USE_CODEC2_AIDL := V1
ifneq (,$(filter aosp_%,$(TARGET_PRODUCT)))
DEVICE_MANIFEST_FILE += \
	device/google/gs101/manifest_media_aosp.xml
else
DEVICE_MANIFEST_FILE += \
	device/google/gs101/manifest_media.xml
endif

DEVICE_MATRIX_FILE := \
	device/google/gs101/compatibility_matrix.xml

DEVICE_PACKAGE_OVERLAYS += device/google/gs101/overlay

# Enforce the Product interface
PRODUCT_PRODUCT_VNDK_VERSION := current
PRODUCT_ENFORCE_PRODUCT_PARTITION_INTERFACE := true

# Init files
PRODUCT_COPY_FILES += \
	$(LOCAL_KERNEL):kernel \
	device/google/gs101/conf/ueventd.gs101.rc:$(TARGET_COPY_OUT_VENDOR)/etc/ueventd.rc

# Recovery files
PRODUCT_COPY_FILES += \
	device/google/gs101/conf/init.recovery.device.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.gs101.rc

ifneq ($(BOARD_WITHOUT_RADIO),true)
PRODUCT_SOONG_NAMESPACES += device/google/gs101/conf
else
PRODUCT_SOONG_NAMESPACES += device/google/gs101/conf/nomodem
endif

# Fstab files
PRODUCT_PACKAGES += \
	fstab.gs101 \
	fstab.gs101.vendor_ramdisk \
	fstab.gs101-fips \
	fstab.gs101-fips.vendor_ramdisk
PRODUCT_COPY_FILES += \
	device/google/gs101/conf/fstab.persist:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.persist

include device/google/gs-common/insmod/insmod.mk

# Insmod config files
PRODUCT_COPY_FILES += \
	$(call find-copy-subdir-files,init.insmod.*.cfg,$(TARGET_KERNEL_DIR),$(TARGET_COPY_OUT_VENDOR_DLKM)/etc)

# For creating dtbo image
PRODUCT_HOST_PACKAGES += \
	mkdtimg

PRODUCT_PACKAGES += \
	messaging

# CHRE
## tools
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
	chre_power_test_client \
	chre_test_client \
	chre_aidl_hal_client
endif

## HAL
include device/google/gs-common/chre/hal.mk
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.context_hub.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.context_hub.xml

# Filesystem management tools
PRODUCT_PACKAGES += \
	linker.vendor_ramdisk \
	tune2fs.vendor_ramdisk \
	resize2fs.vendor_ramdisk

# Userdata Checkpointing OTA GC
PRODUCT_PACKAGES += \
	checkpoint_gc

# Touch
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml

# Sensors
ifneq (,$(findstring tangor, $(TARGET_PRODUCT)))
PRODUCT_COPY_FILES += \
        frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
        frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
        frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
        frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml\
        frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
        frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml
else
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.barometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.barometer.xml \
	frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
	frameworks/native/data/etc/android.hardware.sensor.dynamic.head_tracker.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.dynamic.head_tracker.xml \
	frameworks/native/data/etc/android.hardware.sensor.gyroscope.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.gyroscope.xml \
	frameworks/native/data/etc/android.hardware.sensor.hifi_sensors.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.hifi_sensors.xml \
	frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml\
	frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
	frameworks/native/data/etc/android.hardware.sensor.stepcounter.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepcounter.xml \
	frameworks/native/data/etc/android.hardware.sensor.stepdetector.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.stepdetector.xml
endif

# Add sensor HAL AIDL product packages
PRODUCT_PACKAGES += android.hardware.sensors-service.multihal

# USB HAL
PRODUCT_PACKAGES += \
	android.hardware.usb-service.gs101
PRODUCT_PACKAGES += \
	android.hardware.usb.gadget-service.gs101

# MIDI feature
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.software.midi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.midi.xml

# default usb debug functions
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PROPERTY_OVERRIDES += \
	persist.vendor.usb.usbradio.config=dm
endif

-include hardware/google/pixel/power-libperfmgr/aidl/device.mk

# IRQ rebalancing.
include hardware/google/pixel/rebalance_interrupts/rebalance_interrupts.mk

#
# Audio HALs
#

# Audio Configurations
USE_LEGACY_LOCAL_AUDIO_HAL := false
USE_XML_AUDIO_POLICY_CONF := 1

# Libs
PRODUCT_PACKAGES += \
	com.android.future.usb.accessory

# for now include gralloc here. should come from hardware/google_devices/exynos5
PRODUCT_PACKAGES += \
	libion

# Lyric Camera HAL settings
include device/google/gs-common/camera/lyric.mk
$(call soong_config_set,lyric,soc,gs101)
$(call soong_config_set,google3a_config,soc,gs101)

# WiFi
PRODUCT_PACKAGES += \
	android.hardware.wifi-service \
	wificond \
	libwpa_client \
	WifiOverlay \

# Connectivity
PRODUCT_PACKAGES += \
        ConnectivityOverlay

PRODUCT_PACKAGES_DEBUG += \
	f2fs_io \
	check_f2fs \
	f2fs.fibmap \
	dump.f2fs

# Storage dump
include device/google/gs-common/storage/storage.mk

# Storage health HAL
PRODUCT_PACKAGES += \
	android.hardware.health.storage-service.default

# Battery Mitigation
include device/google/gs-common/battery_mitigation/bcl.mk

# storage pixelstats
-include hardware/google/pixel/pixelstats/device.mk

# Enable project quotas and casefolding for emulated storage without sdcardfs
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Enforce generic ramdisk allow list
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_ramdisk.mk)

# Titan-M
ifeq (,$(filter true, $(BOARD_WITHOUT_DTLS)))
include device/google/gs-common/dauntless/gsc.mk
else
# include dauntless sepolicy to avoid compile error on devices without dauntless
BOARD_VENDOR_SEPOLICY_DIRS += device/google/gs-common/dauntless/sepolicy
endif

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.wifi.aware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.aware.xml \
	frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
	frameworks/native/data/etc/android.hardware.wifi.rtt.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.rtt.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml

# (See b/211840489)
ifneq ($(DISABLE_CAMERA_FS_AF),true)
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml
else
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml
endif

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
	frameworks/native/data/etc/android.hardware.camera.concurrent.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.concurrent.xml \
	frameworks/native/data/etc/android.hardware.camera.full.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.full.xml\
	frameworks/native/data/etc/android.hardware.camera.raw.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.raw.xml\

#PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
	frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
	frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml \
	frameworks/native/data/etc/android.hardware.wifi.passpoint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.passpoint.xml \
	frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
	frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.audio.low_latency.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.low_latency.xml \
	frameworks/native/data/etc/android.hardware.audio.pro.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.audio.pro.xml \

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.software.ipsec_tunnels.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.ipsec_tunnels.xml \

# hw composer HAL
$(call soong_config_set,google_displaycolor,displaycolor_platform,gs101)

PRODUCT_PROPERTY_OVERRIDES += \
	persist.sys.sf.native_mode=2

PRODUCT_CHARACTERISTICS := nosdcard

PRODUCT_PACKAGES += hostapd
PRODUCT_PACKAGES += wpa_supplicant
PRODUCT_PACKAGES += wpa_supplicant.conf

WIFI_PRIV_CMD_UPDATE_MBO_CELL_STATUS := enabled

ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += wpa_cli
PRODUCT_PACKAGES += hostapd_cli
endif

####################################
## VIDEO
####################################

$(call soong_config_set,bigo,soc,gs101)

# 1. Codec 2.0
# for settings used by different C2 hal
include device/google/gs-common/mediacodec/common/mediacodec_common.mk
# for Exynos C2 Hal
include device/google/gs-common/mediacodec/samsung/mediacodec_samsung.mk

####################################

# CBD (CP booting deamon)
CBD_USE_V2 := true
CBD_PROTOCOL_SIT := true

# setup dalvik vm configs.
$(call inherit-product, frameworks/native/build/phone-xhdpi-6144-dalvik-heap.mk)

PRODUCT_TAGS += dalvik.gc.type-precise

# Location
ifeq (,$(filter tangor citron,$(subst _, ,$(TARGET_PRODUCT))))
include device/google/gs-common/gps/brcm/device.mk
endif
# Trusty (KM, GK, Storage)
$(call inherit-product, system/core/trusty/trusty-storage.mk)
$(call inherit-product, system/core/trusty/trusty-base.mk)

# Trusty dump
include device/google/gs-common/trusty/trusty.mk

# Trusty unit test tool
PRODUCT_PACKAGES_DEBUG += \
    trusty-ut-ctrl \
    tipc-test

include device/google/gs101/trusty_metricsd/trusty_metricsd.mk

# TODO: Remove android.hardware.graphics.composer@2.4-impl after boot is verified.
PRODUCT_PACKAGES += \
	android.hardware.graphics.composer@2.4-impl \
	android.hardware.graphics.composer@2.4-service

PRODUCT_ENFORCE_RRO_TARGETS := \
	framework-res

# Dynamic Partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

PRODUCT_COPY_FILES += \
	device/google/gs101/conf/fstab.postinstall:$(TARGET_COPY_OUT_PRODUCT)/etc/fstab.postinstall

# fastbootd
PRODUCT_PACKAGES += \
	android.hardware.fastboot@1.1-impl.pixel \
	fastbootd

#google iwlan
PRODUCT_PACKAGES += \
	Iwlan

ifneq ($(BOARD_WITHOUT_RADIO),true)
# This will be called only if IMSService is building with source code for dev branches.
$(call inherit-product-if-exists, vendor/samsung_slsi/telephony/$(BOARD_USES_SHARED_VENDOR_TELEPHONY)/shannon-ims/device-vendor.mk)

$(call inherit-product-if-exists, vendor/samsung_slsi/telephony/$(BOARD_USES_SHARED_VENDOR_TELEPHONY)/shannon-iwlan/device-vendor.mk)

endif

# Exynos RIL and telephony
# Multi SIM(DSDS)
SIM_COUNT := 2
$(call soong_config_set,sim,sim_count,$(SIM_COUNT))
SUPPORT_MULTI_SIM := true
# Support NR
SUPPORT_NR := true
# Using IRadio 1.6
USE_RADIO_HAL_1_6 := true
# Support SecureElement HAL for HIDL
USE_SE_HIDL := true

#$(call inherit-product, vendor/google_devices/telephony/common/device-vendor.mk)
#$(call inherit-product, vendor/google_devices/gs101/proprietary/device-vendor.mk)

ifneq ($(BOARD_WITHOUT_RADIO),true)
$(call inherit-product-if-exists, vendor/samsung_slsi/telephony/$(BOARD_USES_SHARED_VENDOR_TELEPHONY)/common/device-vendor.mk)
endif

ifeq ($(DEVICE_IS_64BIT_ONLY),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
endif
#$(call inherit-product, hardware/google_devices/exynos5/exynos5.mk)
#$(call inherit-product-if-exists, hardware/google_devices/gs101/gs101.mk)
#$(call inherit-product-if-exists, vendor/google_devices/common/exynos-vendor.mk)
#$(call inherit-product-if-exists, hardware/broadcom/wlan/bcmdhd/firmware/bcm4375/device-bcm.mk)
include device/google/gs-common/sensors/sensors.mk
$(call soong_config_set,usf,target_soc,gs101)

PRODUCT_COPY_FILES += \
	device/google/gs101/default-permissions.xml:$(TARGET_COPY_OUT_PRODUCT)/etc/default-permissions/default-permissions.xml \
	device/google/gs101/component-overrides.xml:$(TARGET_COPY_OUT_VENDOR)/etc/sysconfig/component-overrides.xml

# modem logging binary/configs
PRODUCT_PACKAGES += modem_logging_control

# modem logging configs
PRODUCT_COPY_FILES += \
	device/google/gs101/radio/config/logging.conf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/logging.conf \
	device/google/gs101/radio/config/default.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default.cfg \
	device/google/gs101/radio/config/default.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default.nprf \
	device/google/gs101/radio/config/default_metrics.xml:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_metrics.xml \
	device/google/gs101/radio/config/teamfood_default.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/teamfood_default.cfg \
	device/google/gs101/radio/config/teamfood_default.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/teamfood_default.nprf \
	device/google/gs101/radio/config/teamfood_default_metrics.xml:$(TARGET_COPY_OUT_VENDOR)/etc/modem/teamfood_default_metrics.xml \
	device/google/gs101/radio/config/default_stability.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_stability.cfg \
	device/google/gs101/radio/config/default_stability.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_stability.nprf \
	device/google/gs101/radio/config/default_NAS_RRC.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_NAS_RRC.cfg \
	device/google/gs101/radio/config/default_NAS_RRC.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_NAS_RRC.nprf \
	device/google/gs101/radio/config/default_network.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_network.cfg \
	device/google/gs101/radio/config/default_network.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/default_network.nprf \
	device/google/gs101/radio/config/Pixel_Default.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/Pixel_Default.cfg \
	device/google/gs101/radio/config/Pixel_Default.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/Pixel_Default.nprf \
	device/google/gs101/radio/config/Pixel_Default_metrics.xml:$(TARGET_COPY_OUT_VENDOR)/etc/modem/Pixel_Default_metrics.xml \
	device/google/gs101/radio/config/Pixel_stability.cfg:$(TARGET_COPY_OUT_VENDOR)/etc/modem/Pixel_stability.cfg \
	device/google/gs101/radio/config/Pixel_stability.nprf:$(TARGET_COPY_OUT_VENDOR)/etc/modem/Pixel_stability.nprf

PRODUCT_COPY_FILES += \
	device/google/gs101/radio/gnss_blanking.csv:$(TARGET_COPY_OUT_VENDOR)/etc/modem/gnss_blanking.csv

# Vibrator Diag
PRODUCT_PACKAGES_DEBUG += \
	diag-vibrator \
	diag-vibrator-cs40l25a \
	diag-vibrator-drv2624 \
	$(NULL)

PRODUCT_PACKAGES += \
	android.hardware.health-service.gs101 \
	android.hardware.health-service.gs101_recovery \

# Audio
# Audio HAL Server & Default Implementations
include device/google/gs-common/audio/hidl_gs101.mk

## AoC soong
PRODUCT_SOONG_NAMESPACES += \
        vendor/google/whitechapel/aoc

$(call soong_config_set,aoc,target_soc,$(TARGET_BOARD_PLATFORM))
$(call soong_config_set,aoc,target_product,$(TARGET_PRODUCT))

$(call soong_config_set,android_hardware_audio,run_64bit,true)

# Audio properties
PRODUCT_PROPERTY_OVERRIDES += \
	ro.config.vc_call_vol_steps=7 \
	ro.config.media_vol_steps=25 \
	ro.audio.monitorRotation = true \
	ro.audio.offload_wakelock=false

# declare use of spatial audio
# PRODUCT_PROPERTY_OVERRIDES += \
#	ro.audio.spatializer_enabled=true

# vndservicemanager and vndservice no longer included in API 30+, however needed by vendor code.
# See b/148807371 for reference
PRODUCT_PACKAGES += vndservicemanager
PRODUCT_PACKAGES += vndservice

# TinyTools, debug tool and cs35l41 speaker calibration tool for Audio
ifneq (,$(filter userdebug eng, $(TARGET_BUILD_VARIANT)))
PRODUCT_PACKAGES += \
	tinyplay \
	tinycap \
	tinymix \
	tinypcminfo \
	tinyhostless \
	cplay \
	aoc_hal \
	aoc_tuning_inft \
	crus_sp_cal \
	mahal_test \
	ma_aoc_tuning_test
endif

PRODUCT_PACKAGES += \
	google.hardware.media.c2@1.0-service \
	libgc2_store \
	libgc2_base \
	libgc2_av1_dec \
	libbo_av1 \
	libgc2_cwl \
	libgc2_utils

# Thermal HAL
PRODUCT_PROPERTY_OVERRIDES += persist.vendor.enable.thermal.genl=true

# EdgeTPU
include device/google/gs-common/edgetpu/edgetpu.mk
# Config variables for TPU chip on device.
$(call soong_config_set,edgetpu_config,chip,abrolhos)
# Include the edgetpu targets defined the namespaces below into the final image.
PRODUCT_SOONG_NAMESPACES += \
	vendor/google_devices/gs101/proprietary/gchips/tpu/metrics \
	vendor/google_devices/gs101/proprietary/gchips/tpu/tflite_delegate \
	vendor/google_devices/gs101/proprietary/gchips/tpu/darwinn_logging_service \
	vendor/google_devices/gs101/proprietary/gchips/tpu/nnapi_stable_aidl \
	vendor/google_devices/gs101/proprietary/gchips/tpu/aidl \
	vendor/google_devices/gs101/proprietary/gchips/tpu/hal \
	vendor/google_devices/gs101/proprietary/gchips/tpu/tachyon/tachyon_apis \
	vendor/google_devices/gs101/proprietary/gchips/tpu/tachyon/service
# TPU firmware
PRODUCT_PACKAGES += edgetpu-abrolhos.fw

# Connectivity Thermal Power Manager
PRODUCT_PACKAGES += \
	ConnectivityThermalPowerManager

# A/B support
PRODUCT_PACKAGES += \
	otapreopt_script \
	cppreopts.sh \
	update_engine \
	update_engine_sideload \
	update_verifier

# pKVM
$(call inherit-product, packages/modules/Virtualization/apex/product_packages.mk)
PRODUCT_BUILD_PVMFW_IMAGE := true
ifeq ($(TARGET_PKVM_ENABLED),true)
    PRODUCT_PACKAGES += pkvm_enabler
else
    PRODUCT_COPY_FILES += \
	    device/google/gs101/pkvm/pkvm_experiment.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/pkvm_experiment.rc
endif

# Enable watchdog timeout loop breaker.
PRODUCT_PROPERTY_OVERRIDES += \
	framework_watchdog.fatal_window.second=600 \
	framework_watchdog.fatal_count=3

# Enable zygote critical window.
PRODUCT_PROPERTY_OVERRIDES += \
	zygote.critical_window.minute=10

# Suspend properties
# (b/171433995): Enable short suspend backoffs and reduce max backoff time
PRODUCT_PROPERTY_OVERRIDES += \
    suspend.short_suspend_threshold_millis=2000 \
    suspend.short_suspend_backoff_enabled=true \
    suspend.max_sleep_time_millis=40000

# Enable Incremental on the device
PRODUCT_PROPERTY_OVERRIDES += \
	ro.incremental.enable=true

# Project
include hardware/google/pixel/common/pixel-common-device.mk

# Pixel Logger
include hardware/google/pixel/PixelLogger/PixelLogger.mk

ifneq ($(BOARD_WITHOUT_RADIO),true)
# Telephony
include device/google/gs101/telephony/user.mk
endif

# Wifi ext
include hardware/google/pixel/wifi_ext/device.mk

# Battery Stats Viewer
PRODUCT_PACKAGES_DEBUG += BatteryStatsViewer

# Install product specific framework compatibility matrix
# (TODO: b/169535506) This includes the FCM for system_ext and product partition.
# It must be split into the FCM of each partition.
DEVICE_PRODUCT_COMPATIBILITY_MATRIX_FILE += device/google/gs101/device_framework_matrix_product.xml

# Preopt SystemUI
ifneq ($(RELEASE_SYSTEMUI_USE_SPEED_PROFILE), true)
PRODUCT_DEXPREOPT_SPEED_APPS += SystemUIGoogle  # For internal
PRODUCT_DEXPREOPT_SPEED_APPS += SystemUI        # For AOSP
endif

# Set on-device compilation mode for SystemUI.
ifeq ($(RELEASE_SYSTEMUI_USE_SPEED_PROFILE), true)
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.systemuicompilerfilter=speed-profile
else
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.systemuicompilerfilter=speed
endif

# Keymaster configuration
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.device_id_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.device_id_attestation.xml \
    frameworks/native/data/etc/android.hardware.device_unique_attestation.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.device_unique_attestation.xml

# Use 64-bit dex2oat for better dexopt time.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.dex2oat64.enabled=true

# Call deleteAllKeys if vold detects a factory reset
PRODUCT_VENDOR_PROPERTIES += ro.crypto.metadata_init_delete_all_keys.enabled=true

# Hardware Info Collection
include hardware/google/pixel/HardwareInfo/HardwareInfo.mk

# Touch service
include device/google/gs-common/touch/twoshay/aidl_gs101.mk
include device/google/gs-common/touch/twoshay/twoshay.mk

# Allow longer timeout for incident report generation in bugreport
# Overriding in /product partition instead of /vendor intentionally,
# since it can't be overridden from /vendor.
PRODUCT_PRODUCT_PROPERTIES += \
	dumpstate.strict_run=false
