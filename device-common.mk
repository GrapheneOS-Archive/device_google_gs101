#
# Copyright (C) 2020 The Android Open-Source Project
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

ifneq ($(BOARD_WITHOUT_RADIO),true)
-include vendor/google_devices/gs101/proprietary/telephony/device-vendor.mk
endif
include device/google/gs101/device.mk

ifneq ($(BOARD_WITHOUT_RADIO),true)
# Telephony
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.telephony.carrierlock.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.carrierlock.xml
endif

# Android Verified Boot
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.verified_boot.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.software.verified_boot.xml

# ZramWriteback
-include hardware/google/pixel/mm/device_gki.mk

# Set thermal warm reset
PRODUCT_PRODUCT_PROPERTIES += \
    ro.thermal_warmreset = true

# Trigger fsck on upgrade (305658663)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.preventative_fsck = 1