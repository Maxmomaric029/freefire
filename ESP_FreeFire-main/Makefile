ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
IGNORE_WARNINGS = 1

# SDK de iOS 14.0 mínimo para Free Fire moderno
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

# --- TARGET 1: EL STUB (Inyectar este) ---
TWEAK_NAME = FF_Stub
$(TWEAK_NAME)_FILES = FF_StubLoader.mm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -O2
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation

# --- TARGET 2: EL NÚCLEO (Esconder este) ---
TWEAK_NAME_2 = FF_Core
$(TWEAK_NAME_2)_FILES = Tweak.xm Menu.mm esp.mm Math.cpp $(wildcard KittyMemory/*.cpp) $(wildcard SCLAlertView/*.m)
$(TWEAK_NAME_2)_CFLAGS = -fobjc-arc -O3 -w
$(TWEAK_NAME_2)_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -w
$(TWEAK_NAME_2)_LIBRARIES = substrate
$(TWEAK_NAME_2)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

include $(THEOS_MAKE_PATH)/tweak.mk

# Mensaje post-build
after-all::
	@echo "[!] COMPILACIÓN COMPLETA"
	@echo "1. Inyecta 'FF_Stub.dylib' en el IPA usando Sideloadly/ESign."
	@echo "2. Copia 'FF_Core.dylib' dentro de la carpeta Payload/freefireth.app/"
	@echo "3. (Opcional) Renombra FF_Core a 'libMetalExt.dylib' y actualiza FF_StubLoader.mm"
