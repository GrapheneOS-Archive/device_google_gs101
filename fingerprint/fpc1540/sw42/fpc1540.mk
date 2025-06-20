# Factory build, use HIDL hal & extension so that we can use Test tool
ifneq ( ,$(findstring factory, $(TARGET_PRODUCT)))
include device/google/gs101/fingerprint/fpc1540/sw42/fingerprint_hidl_config_factory.mk

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

else
# Non facotry build, use fingerprint AIDL version
include device/google/gs101/fingerprint/fpc1540/sw42/fingerprint_aidl_config.mk

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.fingerprint.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.fingerprint.xml

endif
