#!/bin/bash
# III.4: que mejora al aumentar p y que mejora al aumentar N.
cd "$(dirname "$0")/bin"
echo "=== Mas hilos, mismo N = 10^8: cambia el tiempo, no el resultado ==="
for p in 1 2 4 8; do ./montecarlo 100000000 $p; done
echo
echo "=== Mismos hilos (p = 8), mas muestras: cambia la precision ==="
for n in 1000000 10000000 100000000 400000000; do
    ./montecarlo $n 8
    awk -v n=$n 'BEGIN { pi=atan2(0,-1); q=pi/4; printf "      error tipico esperado = %.1e\n", 4*sqrt(q*(1-q)/n) }'
done
