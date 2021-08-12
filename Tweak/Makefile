TWEAK_NAME = Tako

$(TWEAK_NAME)_FILES = Tweak.x $(wildcard *.m)
$(TWEAK_NAME)_CFLAGS = -DTHEOS_LEAN_AND_MEAN -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit
$(TWEAK_NAME)_LIBRARIES = kuro
$(TWEAK_NAME)_EXTRA_FRAMEWORKS = Cephei


include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
