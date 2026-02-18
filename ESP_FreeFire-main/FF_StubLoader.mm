#import <dlfcn.h>
#import <unistd.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- EL CARGADOR INVISIBLE (Stub Loader) ---
// Este archivo es el único que se firma e inyecta en el IPA.
// Su misión: esperar, verificar condiciones seguras y cargar el núcleo oculto.

__attribute__((constructor)) static void freefire_stub_loader() {
    // Escuchar el evento de inicio de la app para asegurar que el motor está listo
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        
        // --- BYPASS DE LOGIN ---
        // Generar un delay aleatorio entre 18 y 25 segundos.
        // Esto permite que el usuario pase la pantalla de Garena y entre al lobby 
        // ANTES de que se carguen los hacks detectables.
        int safe_delay = 18 + arc4random_uniform(8);
        
        // Log "Falso" para parecer un framework legítimo de Unity/IronSource
        // NSLog(@"[UnityAds] Initializing SDK v4.8.2...");

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(safe_delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // --- CARGA DEL NÚCLEO OFUSCADO ---
            // Buscamos el dylib real que está escondido en el bundle.
            // RECOMENDACIÓN: Renombrar 'libCoreFF.dylib' a algo como 'libMetalExt.dylib' o 'libUnityGfxHelper.dylib'.
            NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
            NSString *dylibPath = [bundlePath stringByAppendingPathComponent:@"libCoreFF.dylib"];
            
            // Intentar cargar con dlopen (RTLD_NOW | RTLD_GLOBAL)
            void *handle = dlopen([dylibPath UTF8String], RTLD_NOW | RTLD_GLOBAL);
            
            if (handle) {
                // Éxito silencioso. No imprimas nada detectable.
                // NSLog(@"[UnityAds] SDK Ready.");
            } else {
                // Fallo silencioso. Mejor que crashear.
                // NSLog(@"[UnityAds] Failed to init: %s", dlerror());
            }
        });
    }];
}
