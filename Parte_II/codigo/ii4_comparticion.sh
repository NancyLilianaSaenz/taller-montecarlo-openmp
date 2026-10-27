#!/bin/bash
# II.4: variables compartidas y privadas; que pasa sin reduction.
cd "$(dirname "$0")"
N=100000000
echo "=== default(none): el compilador nombra las variables que serian compartidas ==="
echo "$ gcc -O2 -fopenmp pruebas/default_none.c -o default_none -lm"
gcc -O2 -fopenmp pruebas/default_none.c -o bin/default_none -lm 2>&1 | grep -E "error|note" | sed 's/^pruebas\///'
echo
cd bin
echo "=== Sin reduction(+:dentro) ==="
./sin_reduccion $N 1
for r in 1 2 3; do ./sin_reduccion $N 8; done
echo
echo "=== Con reduction(+:dentro) (version final) ==="
for r in 1 2; do ./montecarlo $N 8; done
