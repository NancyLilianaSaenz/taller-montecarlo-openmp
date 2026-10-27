#!/bin/bash
# Compila la referencia del enunciado, la version paralela y las pruebas.
cd "$(dirname "$0")"
mkdir -p bin
set -e
gcc --version | head -1
echo "$ gcc -O2 montecarlo_ref.c -o montecarlo_ref -lm          # tal cual el enunciado"
gcc -O2 montecarlo_ref.c -o bin/montecarlo_ref -lm
echo "$ gcc -O2 -fopenmp montecarlo_secuencial.c -o montecarlo_secuencial -lm"
gcc -O2 -fopenmp montecarlo_secuencial.c -o bin/montecarlo_secuencial -lm
echo "$ gcc -O2 -fopenmp -Wall -Wextra montecarlo.c -o montecarlo -lm"
gcc -O2 -fopenmp -Wall -Wextra montecarlo.c -o bin/montecarlo -lm
echo "$ gcc -O2 -fopenmp -DPLAN=dynamic montecarlo.c -o montecarlo_dynamic -lm"
gcc -O2 -fopenmp -DPLAN=dynamic montecarlo.c -o bin/montecarlo_dynamic -lm
for v in rand_global estado_compartido misma_semilla sin_reduccion semillas_hilos; do
    echo "$ gcc -O2 -fopenmp pruebas/$v.c -o $v -lm"
    gcc -O2 -fopenmp pruebas/$v.c -o bin/$v -lm
done
echo "(todo compilo sin advertencias)"
