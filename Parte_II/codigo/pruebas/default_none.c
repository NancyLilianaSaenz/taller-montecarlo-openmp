/* default_none.c -- PRUEBA para II.4.
   Misma region paralela que la version final, pero con default(none):
   el compilador se niega a compilar y nombra cada variable que, por
   defecto, seria COMPARTIDA (las que no nombra son privadas). */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

#define SEMILLA_BASE 20261018u /* reemplazar por la semilla asignada */
#define BLOQUE 100000L         /* muestras por bloque */

#ifndef PLAN
#define PLAN static            /* -DPLAN=dynamic para comparar (II.5) */
#endif

/* rand_r de glibc avanza su estado con 3 pasos del LCG
   s <- 1103515245*s + 12345 (mod 2^32) en cada llamada,
   y cada muestra (x, y) hace 2 llamadas: 6 pasos por muestra. */
#define LCG_A 1103515245u
#define LCG_C 12345u
#define PASOS_POR_MUESTRA 6ULL

/* Avanza el estado s en k pasos del LCG con O(log k) operaciones. */
static unsigned int saltar(unsigned int s, unsigned long long k) {
    unsigned int a = LCG_A, c = LCG_C;  /* transformacion de 2^j pasos */
    unsigned int A = 1u, C = 0u;        /* transformacion acumulada */
    while (k) {
        if (k & 1ULL) {
            A = a * A;
            C = a * C + c;
        }
        c = a * c + c;
        a = a * a;
        k >>= 1;
    }
    return A * s + C;
}

int main(int argc, char *argv[]) {
    long N = (argc > 1) ? atol(argv[1]) : 100000000L;
    if (argc > 2) omp_set_num_threads(atoi(argv[2]));
    unsigned int semilla = (argc > 3) ? (unsigned int)strtoul(argv[3], NULL, 10)
                                      : SEMILLA_BASE;

    /* El salto debe coincidir con lo que hace rand_r en esta libc. */
    unsigned int prueba = semilla;
    rand_r(&prueba);
    rand_r(&prueba);
    if (prueba != saltar(semilla, PASOS_POR_MUESTRA)) {
        fprintf(stderr, "error: rand_r de esta libc no usa el LCG esperado\n");
        return 1;
    }
    /* Periodo del estado: 2^32. Con mas de 2^32/6 muestras la secuencia
       se repetiria y los bloques dejarian de ser disjuntos. */
    if ((unsigned long long)N * PASOS_POR_MUESTRA > 4294967296ULL)
        fprintf(stderr, "aviso: N supera el periodo del generador\n");

    long nbloques = (N + BLOQUE - 1) / BLOQUE;
    long dentro = 0;

    double t0 = omp_get_wtime();
    #pragma omp parallel for default(none) reduction(+:dentro) schedule(PLAN)
    for (long b = 0; b < nbloques; b++) {
        unsigned int estado =
            saltar(semilla, (unsigned long long)b * BLOQUE * PASOS_POR_MUESTRA);
        long fin = (b + 1) * BLOQUE < N ? (b + 1) * BLOQUE : N;
        for (long i = b * BLOQUE; i < fin; i++) {
            double x = rand_r(&estado) / (double)RAND_MAX;
            double y = rand_r(&estado) / (double)RAND_MAX;
            if (x * x + y * y <= 1.0)
                dentro++;
        }
    }
    double t = omp_get_wtime() - t0;

    double pi = 4.0 * dentro / (double)N;
    printf("default_none p=%d N=%ld dentro=%ld pi=%.6f |error|=%.2e T=%.4f s\n",
           omp_get_max_threads(), N, dentro, pi, fabs(pi - M_PI), t);
    return 0;
}
