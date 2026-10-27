#!/bin/bash
# Ejecuta el programa varias veces seguidas con p hilos (lo usa frecuencia.ps1).
# Uso: bash carga.sh <hilos> <repeticiones>
cd "$(dirname "$0")/bin"
for r in $(seq "$2"); do ./montecarlo 100000000 "$1"; done > "/tmp/frec_$1.txt"
sed 's/.*T=\([0-9.]*\).*/\1/' "/tmp/frec_$1.txt" | sort -n | awk '{ a[NR] = $1 } END { print a[int((NR + 1) / 2)] }' > "/tmp/frec_$1.med"
