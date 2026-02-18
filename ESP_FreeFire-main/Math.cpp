#include <cmath>
#include <cstdlib>
#include <ctime>
#include "FF_Obfuscation.h"

// --- MOTOR MATEMÁTICO HUMANIZADO (Anti-Report) ---
// En lugar de apuntar perfectamente, introducimos errores y vibraciones.

static bool seeded = false;

// Método de Jitter: Agrega vibración aleatoria a las coordenadas
void AddJitter(float* x, float* y, float intensity) {
    if (!seeded) { srand(time(NULL)); seeded = true; }
    
    // Generar un offset aleatorio pequeño (-0.5 a +0.5 ajustado por intensidad)
    float jitterX = ((float)(rand() % 100) / 100.0f - 0.5f) * intensity;
    float jitterY = ((float)(rand() % 100) / 100.0f - 0.5f) * intensity;
    
    *x += jitterX;
    *y += jitterY;
}

// Check de Fallo Intencional (35% Fail Rate)
// Devuelve true si debemos fallar el disparo a propósito
bool ShouldMiss() {
    if (!seeded) { srand(time(NULL)); seeded = true; }
    
    // Si g_Humanize está activo, calculamos probabilidad de fallo
    if (g_Humanize) {
        int r = rand() % 100;
        // Si el número es menor que el FailRate (ej: 35), fallamos.
        if (r < (int)(g_FailRate * 100.0f)) {
            return true;
        }
    }
    return false;
}

// Cálculo de Ángulo de Visión (FOV)
float GetFOV(float aimX, float aimY, float screenW, float screenH) {
    float cx = screenW / 2.0f;
    float cy = screenH / 2.0f;
    return sqrt(pow(cx - aimX, 2) + pow(cy - aimY, 2));
}

// Helper ofuscado para distancia
float f_dist3(float x1, float y1, float z1, float x2, float y2, float z2) {
    return sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2) + pow(z2 - z1, 2));
}

#endif
