#import "Macros.h"
#import "Vector3.hpp"
#import "esp.h"
#import "Obfuscate.h"
#import "Quaternion.hpp"
#import <string>
#import <vector>

using namespace std;

// ==========================================
// OFFSETS & CONFIG (offsets2.txt & a.txt)
// ==========================================
#define OFF_LocalPlayer 0x44
#define OFF_sAim1 0x4a0 // isShooting
#define OFF_sAim2 0x874 // weaponData
#define OFF_sAim3 0x38  // startPos
#define OFF_sAim4 0x2c  // aimPosition (Destination)
#define OFF_NoReload 0x89
#define OFF_NoRecoil 0xC

// Variables de estado
bool silentAimActive = false;
bool noRecoilActive = false;
bool noReloadActive = false;

// ==========================================
// FUNCIONES DE AYUDA / HELPERS
// ==========================================

int get_Health(void *_this){
  if (!_this) return 0;
  int (*hp)(void *instance) = (int (*)(void *))getRealOffset(0x1030ACDDC);
  return hp(_this);
}

void *GetLocalPlayer() {
    // Offset original del proyecto estable para obtener LocalPlayer
    void *(*local)() = (void *(*)())getRealOffset(0x1027EB588);
    return (void *)local();
}

Vector3 getPosition(void *component){
  Vector3 out(0,0,0);
  if (!component) return out;
  void *(*get_trans)(void *) = (void *(*)(void *))getRealOffset(0x10411F080);
  void (*get_pos)(void *, Vector3 *) = (void (*)(void *, Vector3 *))getRealOffset(0x104160870);
  
  void *transform = get_trans(component);
  if (transform) get_pos(transform, &out);
  return out;
}

void *camera(){
    void *(*get_main)() = (void *(*)())getRealOffset(0x10411D678);
    return (void *) get_main();
}

Vector3 WorldToScreenPoint(void *cam, Vector3 pos) {
    Vector3 (*W2S)(void *, Vector3, int) = (Vector3 (*)(void *, Vector3, int))getRealOffset(0x10411CDC4);
    return W2S(cam, pos, 2);
}

// ==========================================
// LÓGICA DE AIMKILL (Portado de a.txt)
// ==========================================

void ProcessSilentAim(void *localPlayer, void *bestTarget) {
    if (!localPlayer || !bestTarget) return;

    // Verificar si está disparando (sAim1)
    bool isShooting = *(bool *)((uintptr_t)localPlayer + OFF_sAim1);
    
    if (isShooting) {
        uintptr_t weaponData = *(uintptr_t *)((uintptr_t)localPlayer + OFF_sAim2);
        if (weaponData) {
            Vector3 targetHead = getPosition(bestTarget);
            targetHead.Y += 0.1f; // Ajuste para la cabeza

            Vector3 startPos = *(Vector3 *)(weaponData + OFF_sAim3);
            Vector3 aimPosition = {
                targetHead.X - startPos.X,
                targetHead.Y - startPos.Y,
                targetHead.Z - startPos.Z
            };

            // Escribir la nueva dirección de la bala (sAim4)
            *(Vector3 *)(weaponData + OFF_sAim4) = aimPosition;
        }
    }
}

// ==========================================
// HOOKS PRINCIPALES
// ==========================================

static esp* es;
void (*LateUpdate)(void* _this);
void _LateUpdate(void* _this) {
    if (_this != NULL) {
        void *localPlayer = GetLocalPlayer();
        void *myCam = camera();
        
        if (localPlayer && myCam) {
            // Actualizar estado del AimKill desde el menú
            silentAimActive = [switches isSwitchOn:@"Silent Aim"];
            
            if (silentAimActive && _this != localPlayer) {
                ProcessSilentAim(localPlayer, _this);
            }
        }
    }
    LateUpdate(_this);
}

void setup(){
    // Hooks de estabilidad (NO TOCAR PARA EVITAR CRASH)
    HOOK(0x1030A21BC, _LateUpdate, LateUpdate);

    // --- MENÚ DE OPCIONES ---
    [switches addSwitch:@"Silent Aim" description:@"AimKill automático al disparar"];
    [switches addOffsetSwitch:@"No Recoil" 
                  description:@"Elimina el retroceso" 
                  offsets:{0x1030B1B00} // Ejemplo, ajustar con dump.cs
                  bytes:{"00 00 80 52 C0 03 5F D6"}];
    
    [switches addOffsetSwitch:@"No Reload" 
                  description:@"Fuego instantáneo sin recarga" 
                  offsets:{0x1030B1A89} 
                  bytes:{"00 00 80 52 C0 03 5F D6"}];

    [switches addSwitch:@"ESP" description:@"Activar visuales"];
}

void setupMenu() {
    menu = [[Menu alloc] initWithTitle:@"FREE FIRE AIMKILL" 
                            titleColor:[UIColor whiteColor] 
                            titleFont:@"San Francisco" 
                            credits:@"Mod Menu By Mxzzy\nStable Logic" 
                            headerColor:UIColorFromHex(0xBD0000) 
                            switchOffColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] 
                            switchOnColor:[UIColor redColor] 
                            switchTitleFont:@"San Francisco" 
                            switchTitleColor:[UIColor whiteColor] 
                            infoButtonColor:[UIColor whiteColor] 
                            maxVisibleSwitches:5 
                            menuWidth:280 
                            menuIcon:@"" 
                            menuButton:@""];
    setup();
}

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
    timer(5) {
        UIWindow *main = [UIApplication sharedApplication].keyWindow;
        es = [[esp alloc] initWithFrame:main];
        setupMenu();
    });     
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
