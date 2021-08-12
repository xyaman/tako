export ARCHS = arm64 arm64e
export SYSROOT = $(THEOS)/sdks/iPhoneOS13.0.sdk
export PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/
export TARGET = iphone:clang:14.5:13.0

INSTALL_TARGET_PROCESSES = SpringBoard

SUBPROJECTS += Tweak

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk