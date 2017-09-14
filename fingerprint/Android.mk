LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
    FingerprintWrapper.cpp

LOCAL_SHARED_LIBRARIES := \
    libhardware liblog libcutils

LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE := fingerprint.$(TARGET_DEVICE)
LOCAL_MODULE_TAGS := optional
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MULTILIB := 64

include $(BUILD_SHARED_LIBRARY)
