/* montecarlo_secuencial.c -- version secuencial de referencia (la del enunciado)
   con medicion de tiempo mediante omp_get_wtime().
   Uso: ./montecarlo_secuencial <numero de muestras>
   Compilar: gcc -O2 -fopenmp montecarlo_secuencial.c -o montecarlo_secuencial -lm */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <omp.h>

int main(int argc, char *argv[]) {
    long N = (argc > 1) ? atol(argv[1]) : 100000000L;
    unsigned int estado = 20261018u; /* semilla del generador */
    long dentro = 0;

    double t0 = omp_get_wtime();
    for (long i = 0; i < N; i++) {
        double x = rand_r(&estado) / (double)RAND_MAX;
        double y = rand_r(&estado) / (double)RAND_MAX;
        if (x * x + y * y <= 1.0)
            dentro++;
    }
    double t = omp_get_wtime() - t0;

    double pi = 4.0 * dentro / (double)N;
    printf("secuencial N=%ld dentro=%ld pi=%.6f |error|=%.2e T=%.4f s\n",
           N, dentro, pi, fabs(pi - M_PI), t);
    return 0;
}
