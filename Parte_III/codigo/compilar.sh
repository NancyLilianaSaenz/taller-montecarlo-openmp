#!/bin/bash
# Compila el programa paralelo de la parte II, la referencia secuencial
# y la prueba de sobrecosto.
cd "$(dirname "$0")"
mkdir -p bin
set -e
gcc --version | head -1
echo "$ gcc -O2 -fopenmp montecarlo_secuencial.c -o montecarlo_secuencial -lm"
gcc -O2 -fopenmp montecarlo_secuencial.c -o bin/montecarlo_secuencial -lm
echo "$ gcc -O2 -fopenmp -Wall -Wextra montecarlo.c -o montecarlo -lm"
gcc -O2 -fopenmp -Wall -Wextra montecarlo.c -o bin/montecarlo -lm
echo "$ gcc -O2 -fopenmp -Wall sobrecosto.c -o sobrecosto"
gcc -O2 -fopenmp -Wall sobrecosto.c -o bin/sobrecosto
echo "(todo compilo sin advertencias)"
echo
echo "$ lscpu | grep -E 'Model name|^CPU\(s\)|Thread|Core|Socket|MHz|L1d|L2|L3'"
lscpu | grep -E 'Model name|^CPU\(s\)|Thread|Core|Socket|MHz|L1d|L2|L3'
