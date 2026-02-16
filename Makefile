# Configuración definitiva para GitHub Actions
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# No errores por warnings
IGNORE_WARNINGS = 1

# Forzamos TARGET a la versión más reciente disponible en el sistema
TARGET = iphone:clang:latest:8.0

## Common frameworks ##
PROJ_COMMON_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

## source files ##
KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
SCLALERTVIEW_SRC = $(wildcard SCLAlertView/*.m)
MENU_SRC = Menu.mm

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = espff

$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG

ifeq ($(IGNORE_WARNINGS),1)
  $(TWEAK_NAME)_CFLAGS += -w
  $(TWEAK_NAME)_CCFLAGS += -w
endif

$(TWEAK_NAME)_FILES = Tweak.xm $(MENU_SRC) $(KITTYMEMORY_SRC) $(SCLALERTVIEW_SRC) esp.mm
$(TWEAK_NAME)_LIBRARIES += substrate
$(TWEAK_NAME)_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9  || :"
