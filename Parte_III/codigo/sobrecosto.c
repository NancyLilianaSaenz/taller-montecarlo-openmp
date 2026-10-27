/* sobrecosto.c -- mide cuanto cuesta crear los hilos, abrir y cerrar una
   region paralela y hacer una reduccion, para compararlo con el tiempo total
   del calculo de pi.
   Uso: ./sobrecosto <hilos> */
#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define REPETICIONES 20000

int main(int argc, char *argv[]) {
    int p = (argc > 1) ? atoi(argv[1]) : 4;
    omp_set_num_threads(p);
    volatile long basura = 0;

    /* La primera region crea los hilos. */
    double t0 = omp_get_wtime();
    #pragma omp parallel
    { if (omp_get_thread_num() < 0) basura++; }
    double creacion = omp_get_wtime() - t0;

    /* Las siguientes reutilizan los hilos: solo despertarlos y esperarlos. */
    t0 = omp_get_wtime();
    for (int r = 0; r < REPETICIONES; r++) {
        #pragma omp parallel
        { if (omp_get_thread_num() < 0) basura++; }
    }
    double region = (omp_get_wtime() - t0) / REPETICIONES;

    t0 = omp_get_wtime();
    for (int r = 0; r < REPETICIONES; r++) {
        long s = 0;
        #pragma omp parallel for reduction(+:s)
        for (int i = 0; i < p; i++)
            s += i;
        basura += s;
    }
    double reduccion = (omp_get_wtime() - t0) / REPETICIONES;

    printf("p=%d  crear hilos: %7.1f us   region: %6.2f us   parallel for + reduction: %6.2f us\n",
           p, creacion * 1e6, region * 1e6, reduccion * 1e6);
    return 0;
}
