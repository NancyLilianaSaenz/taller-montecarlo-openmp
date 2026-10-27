#!/bin/bash
# III.3: costo de crear/sincronizar hilos y de la reduccion.
cd "$(dirname "$0")/bin"
echo "=== Costo de los hilos y de la reduccion (promedio de 20000 repeticiones) ==="
for p in 1 2 4 8; do ./sobrecosto $p; done
echo "(1 us = 0,000001 s; el calculo de pi con N = 10^8 tarda unos 300 000 a 1 400 000 us)"
