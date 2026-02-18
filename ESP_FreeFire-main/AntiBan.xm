#import <substrate.h>
#import <sys/sysctl.h>
#import <unistd.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>

// ==========================================================
// ANTI-BAN & BYPASS SYSTEM (Free Fire / Garena)
// ==========================================================

// 1. PTRACE BYPASS (Anti-Debug)
// El juego usa ptrace(PT_DENY_ATTACH) para evitar que se le adjunte un debugger.
// Retornamos 0 para decir "todo bien" sin hacer nada.
static int (*orig_ptrace)(int, pid_t, caddr_t, int);
int new_ptrace(int _request, pid_t _pid, caddr_t _addr, int _data) {
    if(_request == 31) { // PT_DENY_ATTACH
        return 0; 
    }
    return orig_ptrace(_request, _pid, _addr, _data);
}

// 2. SYSCTL BYPASS (Anti-Debug / Integrity)
// Oculta la flag P_TRACED que indica que el proceso está siendo modificado/debuggeado.
static int (*orig_sysctl)(int *, u_int, void *, size_t *, void *, size_t);
int new_sysctl(int *name, u_int namelen, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
    int ret = orig_sysctl(name, namelen, oldp, oldlenp, newp, newlen);
    
    if (namelen == 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID) {
        // Si el juego pregunta por su propio proceso
        if (oldp) {
            struct kinfo_proc *kp = (struct kinfo_proc *)oldp;
            // Quitamos la bandera P_TRACED para parecer "limpios"
            if ((kp->kp_proc.p_flag & 0x800) != 0) { 
                kp->kp_proc.p_flag &= ~0x800;
            }
        }
    }
    return ret;
}

// 3. FILE SYSTEM BYPASS (Jailbreak Detection)
// Engaña al juego cuando busca archivos de Cydia, Substrate o temas.
static int (*orig_access)(const char *, int);
int new_access(const char *path, int mode) {
    if (path) {
        NSString *pathStr = [NSString stringWithUTF8String:path];
        if ([pathStr containsString:@"Cydia"] || 
            [pathStr containsString:@"MobileSubstrate"] || 
            [pathStr containsString:@"sshd"] ||
            [pathStr containsString:@"apt"]) {
            return -1; // "Archivo no existe"
        }
    }
    return orig_access(path, mode);
}

// 4. MODULE BYPASS (Unity / Garena MSDK Integrity)
// Garena suele usar una función "IsDeviceRooted" o "CheckEnvironment".
// Como no tenemos el nombre exacto, bloqueamos exit() y abort() para evitar crash por detección.

static void (*orig_exit)(int);
void new_exit(int status) {
    // Si el juego intenta cerrarse solo (posible detección), lo ignoramos.
    // Solo permitimos salir si el status es normal (0) aunque a veces detección usa 0.
    // Mejor bloquearlo temporalmente o logearlo.
    return; 
}

// Inicializador del Anti-Ban
void InitAntiBan() {
    MSHookFunction((void *)ptrace, (void *)new_ptrace, (void **)&orig_ptrace);
    MSHookFunction((void *)sysctl, (void *)new_sysctl, (void **)&orig_sysctl);
    MSHookFunction((void *)access, (void *)new_access, (void **)&orig_access);
    MSHookFunction((void *)exit, (void *)new_exit, (void **)&orig_exit);
}
