#!/bin/bash
# II.2: version paralela. Eleccion de p, flujos disjuntos y reproducibilidad.
cd "$(dirname "$0")/bin"
N=100000000
echo "=== p como argumento (omp_set_num_threads) ==="
for p in 1 2 4 8; do ./montecarlo $N $p; done
echo
echo "=== p con la variable OMP_NUM_THREADS ==="
for p in 2 4; do echo "$ OMP_NUM_THREADS=$p ./montecarlo $N"; OMP_NUM_THREADS=$p ./montecarlo $N; done
echo
echo "=== Repeticion con p = 8 (debe dar siempre lo mismo) ==="
for r in 1 2 3; do ./montecarlo $N 8; done
echo
echo "=== Donde empieza el flujo de cada hilo (p = 4) ==="
./semillas_hilos $N 4
