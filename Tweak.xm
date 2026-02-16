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
#define OFF_Weapon 0x35c
#define OFF_WeaponData 0x54

// Variables de estado
void *targetEnemy = NULL;
float bestDist = 99999.0f;

// ==========================================
// FUNCIONES DE AYUDA / HELPERS
// ==========================================

int get_Health(void *_this){
  if (!_this) return 0;
  int (*hp)(void *instance) = (int (*)(void *))getRealOffset(0x1030ACDDC);
  return hp(_this);
}

void *GetLocalPlayer() {
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

// ==========================================
// LÓGICA DE AIMKILL & COMBATE
// ==========================================

void ProcessSilentAim(void *localPlayer, void *bestTarget) {
    if (!localPlayer || !bestTarget) return;

    @try {
        bool isShooting = *(bool *)((uintptr_t)localPlayer + OFF_sAim1);
        if (isShooting) {
            uintptr_t weaponData = *(uintptr_t *)((uintptr_t)localPlayer + OFF_sAim2);
            if (weaponData) {
                Vector3 targetHead = getPosition(bestTarget);
                targetHead.Y += 0.15f; 

                Vector3 startPos = *(Vector3 *)(weaponData + OFF_sAim3);
                Vector3 aimPosition = {
                    targetHead.X - startPos.X,
                    targetHead.Y - startPos.Y,
                    targetHead.Z - startPos.Z
                };

                *(Vector3 *)(weaponData + OFF_sAim4) = aimPosition;
            }
        }
    } @catch (NSException *e) {}
}

void ProcessNoRecoil(void *localPlayer) {
    if (!localPlayer || ![switches isSwitchOn:@"No Recoil"]) return;
    
    @try {
        uintptr_t weapon = *(uintptr_t *)((uintptr_t)localPlayer + OFF_Weapon);
        if (weapon) {
            uintptr_t weaponData = *(uintptr_t *)(weapon + OFF_WeaponData);
            if (weaponData) {
                *(float *)(weaponData + OFF_NoRecoil) = 0.0f;
            }
        }
    } @catch (NSException *e) {}
}

// ==========================================
// HOOKS PRINCIPALES
// ==========================================

static esp* es;
void (*LateUpdate)(void* _this);
void _LateUpdate(void* _this) {
    if (_this != NULL) {
        void *localPlayer = GetLocalPlayer();
        
        if (localPlayer) {
            ProcessNoRecoil(localPlayer);

            if (_this != localPlayer) {
                Vector3 myPos = getPosition(localPlayer);
                Vector3 enPos = getPosition(_this);
                float dist = Vector3::Distance(myPos, enPos);

                if (dist < bestDist && get_Health(_this) > 0) {
                    bestDist = dist;
                    targetEnemy = _this;
                }

                if ([switches isSwitchOn:@"Silent Aim"] && targetEnemy) {
                    ProcessSilentAim(localPlayer, targetEnemy);
                }
            }
        }
    }
    bestDist = 99999.0f; 
    LateUpdate(_this);
}

void setup(){
    HOOK(0x1030A21BC, _LateUpdate, LateUpdate);

    [switches addSwitch:@"Silent Aim" description:@"AimKill automático al disparar"];
    [switches addSwitch:@"No Recoil" description:@"Elimina el retroceso del arma"];
    
    [switches addOffsetSwitch:@"No Reload" 
                  description:@"Fuego instantáneo sin recarga" 
                  offsets:{0x1030B1A89} 
                  bytes:{"00 00 80 52 C0 03 5F D6"}];

    [switches addSwitch:@"ESP" description:@"Activar visuales"];
}

void setupMenu() {
    menu = [[Menu alloc] initWithTitle:@"FREE FIRE SUPREME" 
                            titleColor:[UIColor whiteColor] 
                            titleFont:@"San Francisco" 
                            credits:@"Mod Menu By Mxzzy\nEverything Implemented" 
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
