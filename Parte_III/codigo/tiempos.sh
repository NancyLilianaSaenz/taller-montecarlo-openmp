#!/bin/bash
# Protocolo de la parte III: N = 10^8, p en {1, 2, 4, 8}, 7 rondas intercaladas.
# T(1) es el programa secuencial; tambien se mide la version paralela con p = 1.
cd "$(dirname "$0")/bin"
N=100000000
SAL=../../resultados/tiempos.txt
: > $SAL
./montecarlo $N 4 > /dev/null   # calentamiento
printf "ronda     sec     p=1     p=2     p=4     p=8\n"
for r in 1 2 3 4 5 6 7; do
    linea="  $r  "
    out=$(./montecarlo_secuencial $N); echo "sec $out" >> $SAL
    linea="$linea $(printf '%7s' $(echo "$out" | sed 's/.*T=\([0-9.]*\).*/\1/'))"
    for p in 1 2 4 8; do
        out=$(./montecarlo $N $p); echo "par $out" >> $SAL
        linea="$linea $(printf '%7s' $(echo "$out" | sed 's/.*T=\([0-9.]*\).*/\1/'))"
    done
    echo "$linea"
done
echo
tiempos() { grep "^$1" $SAL | sed 's/.*T=\([0-9.]*\).*/\1/' | sort -n; }
{
    echo "sec 1 $(tiempos 'sec ' | tr '\n' ' ')"
    for p in 1 2 4 8; do echo "par $p $(tiempos "par p=$p " | tr '\n' ' ')"; done
} | awk '
{ n = NF - 2; for (i = 1; i <= n; i++) t[i] = $(i + 2)
  s = 0; for (i = 1; i <= n; i++) s += t[i]
  med = t[(n + 1) / 2]; if ($1 == "sec") T1 = med
  nombre = ($1 == "sec") ? "1 (secuencial)" : "p=" $2 " (paralelo)"
  S = T1 / med; E = S / $2
  if ($1 == "par" && $2 == 4) S4 = S
  if ($1 == "par") { Sp[$2] = S }
  printf "%-16s mediana %.4f  prom %.4f  min %.4f  max %.4f   S=%.3f  E=%.3f\n", nombre, med, s / n, t[1], t[n], S, E }
END {
  f = (1 - 1 / S4) / (1 - 1 / 4)
  printf "\nf (de S(4) = %.3f) = (1 - 1/S)/(1 - 1/4) = %.3f   ->  1 - f = %.3f\n", S4, f, 1 - f
  printf "Karp-Flatt: e(2) = %.3f   e(4) = %.3f   e(8) = %.3f\n",
         (1/Sp[2] - 1/2)/(1 - 1/2), (1/Sp[4] - 1/4)/(1 - 1/4), (1/Sp[8] - 1/8)/(1 - 1/8) }'
echo "Conteos distintos en las 35 corridas: $(sed 's/.*dentro=\([0-9]*\).*/\1/' $SAL | sort -u | tr '\n' ' ')"
