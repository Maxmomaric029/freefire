#ifndef FF_OBFUSCATION_H
#define FF_OBFUSCATION_H

#import <Foundation/Foundation.h>
#include <string>
#include <cstdlib>

// --- VARIABLES GLOBALES DE SEGURIDAD ---
extern bool g_SafeMode;      // Si es true, desactiva funciones riesgosas
extern bool g_Humanize;      // Si es true, aplica jitter y fallos
extern float g_FailRate;     // Porcentaje de disparos que deben fallar (0.0 - 1.0)

// --- RENOMBRADO DE SÍMBOLOS (Anti-Analysis) ---
#define FF_CoreLoad       f_x9a8
#define FF_HackLoop       f_b7c6
#define FF_AimbotLogic    f_z1y2
#define FF_GetEntity      f_h3j4
#define FF_WorldToScreen  f_k5l6

// --- ENCRIPTACIÓN DE STRINGS (XOR) ---
// Clave rotativa simple para evitar detección estática de strings como "Garena"
static inline std::string ff_xor(const char* data, size_t len, char key) {
    std::string res = "";
    for (size_t i = 0; i < len; i++) res += data[i] ^ key;
    return res;
}

// Macro para usar en el código: FF_STR("Texto", 'k')
#define FF_STR(str, key) ff_xor(str, sizeof(str)-1, key).c_str()

// --- OFUSCACIÓN DE OFFSETS ---
#define OFF_KEY 0x99AA88BB
static inline uint64_t ff_off(uint64_t val) { return val ^ OFF_KEY; }

// --- MACROS DE SAFE MODE ---
// Si estamos en safe mode, retornamos inmediatamente o bloqueamos la ejecución
#define CHECK_SAFE_MODE if(g_SafeMode) return;
#define CHECK_SAFE_VAL(x) if(g_SafeMode) return x;

#endif
