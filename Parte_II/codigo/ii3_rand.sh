#!/bin/bash
# II.3: por que no compartir el generador ni repetir la semilla.
cd "$(dirname "$0")/bin"
N=100000000
echo "=== Problema 1a: todos los hilos llaman a rand() (estado global) ==="
./rand_global $N 1
for r in 1 2 3; do ./rand_global $N 8; done
echo
echo "=== Problema 1b: estado de rand_r compartido, sin ninguna proteccion ==="
./estado_compartido $N 1
for r in 1 2 3; do ./estado_compartido $N 8; done
echo
echo "=== Problema 2: cada hilo con su generador pero con la MISMA semilla ==="
for p in 1 2 4 8; do ./misma_semilla $N $p; done
echo "--- referencia: secuencial con solo N/p muestras ---"
for p in 2 4 8; do ./montecarlo_secuencial $((N/p)); done
echo
echo "=== Version final, para comparar ==="
./montecarlo $N 8
