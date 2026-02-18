#ifndef GAME_STRUCTS_HPP
#define GAME_STRUCTS_HPP

#include <cstdint>
#include "FF_Obfuscation.h"

// --- OFFSETS DE FREE FIRE (Encriptados) ---
// Key para desencriptar: 0x99AA88BB

// HealthOffset (0x1A8) -> 0x1A8 ^ 0x99AA88BB = ...
// MaxHealthOffset (0x1AC) -> 0x1AC ^ 0x99AA88BB = ...
// ArmorOffset (0x1B0) -> 0x1B0 ^ 0x99AA88BB = ...
// WeaponOffset (0x6C0) -> 0x6C0 ^ 0x99AA88BB = ...
// IsDead (0x24) -> 0x24 ^ 0x99AA88BB = ...

// --- STRUCTS OFUSCADOS (s_xxxx) ---
// Para evitar detección de análisis estático

struct s_Vec3 {
    float x, y, z;
    s_Vec3 operator+(const s_Vec3& v) const { return {x + v.x, y + v.y, z + v.z}; }
    s_Vec3 operator-(const s_Vec3& v) const { return {x - v.x, y - v.y, z - v.z}; }
    s_Vec3 operator*(float f) const { return {x * f, y * f, z * f}; }
};

struct s_Quat {
    float x, y, z, w;
};

// Entidad Genérica (Jugador/NPC)
class s_Entity {
public:
    char _pad0[0x24];
    bool is_dead;        // 0x24
    char _pad1[0x183];   // Padding hasta 0x1A8
    int health;          // 0x1A8
    int max_health;      // 0x1AC
    int armor;           // 0x1B0
    // ... más campos ...
    
    // Método helper ofuscado para obtener posición
    s_Vec3 get_pos() {
        // Lógica de obtención de posición (simulada)
        return *(s_Vec3*)((uintptr_t)this + 0x80); 
    }
};

// Wrapper para transformaciones de Unity
class s_Transform {
public:
    s_Vec3 position;
    s_Quat rotation;
};

#endif
