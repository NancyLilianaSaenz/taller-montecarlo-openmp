#!/bin/bash
# II.1: version secuencial con N = 10^8, error y tiempo T(1).
cd "$(dirname "$0")/bin"
N=100000000
echo "=== Programa del enunciado, sin cambios ==="
echo "$ ./montecarlo_ref $N"
./montecarlo_ref $N
echo
echo "=== Misma version con omp_get_wtime() (7 corridas) ==="
./montecarlo_secuencial $N > /dev/null   # calentamiento
for r in 1 2 3 4 5 6 7; do ./montecarlo_secuencial $N; done | tee /tmp/ii1_t.txt
echo "T(1) = mediana de las 7 corridas = $(sed 's/.*T=\([0-9.]*\).*/\1/' /tmp/ii1_t.txt | sort -n | sed -n 4p) s"
echo
echo "=== Error tipico esperado ==="
awk -v n=$N 'BEGIN { pi=atan2(0,-1); q=pi/4;
  printf "q = pi/4 = %.6f   sigma = 4*sqrt(q(1-q)/N) = %.2e   1/sqrt(N) = %.0e\n", q, 4*sqrt(q*(1-q)/n), 1/sqrt(n) }'
