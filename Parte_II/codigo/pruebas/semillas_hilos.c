/* semillas_hilos.c -- PRUEBA para II.2.
   Usa el mismo reparto que la version final (parallel for schedule(static)
   sobre bloques de BLOQUE muestras) y muestra, para cada hilo, en que
   muestra empieza y con que estado del generador. Luego comprueba ese
   estado avanzando rand_r de forma secuencial desde la semilla base.
   Uso: ./semillas_hilos <N> <hilos> */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define SEMILLA_BASE 20261018u
#define BLOQUE 100000L
#define LCG_A 1103515245u
#define LCG_C 12345u
#define PASOS_POR_MUESTRA 6ULL

static unsigned int saltar(unsigned int s, unsigned long long k) {
    unsigned int a = LCG_A, c = LCG_C, A = 1u, C = 0u;
    while (k) {
        if (k & 1ULL) { A = a * A; C = a * C + c; }
        c = a * c + c;
        a = a * a;
        k >>= 1;
    }
    return A * s + C;
}

int main(int argc, char *argv[]) {
    long N = (argc > 1) ? atol(argv[1]) : 100000000L;
    int p = (argc > 2) ? atoi(argv[2]) : 4;
    omp_set_num_threads(p);
    long nbloques = (N + BLOQUE - 1) / BLOQUE;
    long primero[64], ultimo[64];
    for (int k = 0; k < p; k++) { primero[k] = -1; ultimo[k] = -1; }

    #pragma omp parallel for schedule(static)
    for (long b = 0; b < nbloques; b++) {
        int k = omp_get_thread_num();
        if (primero[k] < 0) primero[k] = b;
        ultimo[k] = b;
    }

    printf("N=%ld  p=%d  N/p=%ld  semilla base=%u\n", N, p, N / p, SEMILLA_BASE);
    printf("hilo  bloques      muestras que genera        estado inicial  rand_r secuencial  ok\n");
    unsigned int s = SEMILLA_BASE;   /* avance secuencial real con rand_r */
    long hecho = 0;
    for (int k = 0; k < p; k++) {
        long ini = primero[k] * BLOQUE;
        long fin = (ultimo[k] + 1) * BLOQUE - 1;
        unsigned int salto = saltar(SEMILLA_BASE, (unsigned long long)ini * PASOS_POR_MUESTRA);
        for (; hecho < ini; hecho++) { rand_r(&s); rand_r(&s); }
        printf("%4d  %4ld-%-4ld  %10ld - %-10ld   %14u  %17u  %s\n", k, primero[k], ultimo[k],
               ini, fin, salto, s, salto == s ? "si" : "NO");
    }
    return 0;
}
