"""Lee resultados/tiempos.txt y dibuja el speedup medido frente al ideal y a Amdahl.
Uso: python analisis.py  ->  evidencias/speedup.png"""
import re
import statistics
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

AQUI = Path(__file__).resolve().parent
tiempos = {}
for linea in (AQUI.parent / "resultados" / "tiempos.txt").read_text().splitlines():
    t = float(re.search(r"T=([0-9.]+)", linea).group(1))
    clave = "sec" if linea.startswith("sec") else int(re.search(r"p=(\d+)", linea).group(1))
    tiempos.setdefault(clave, []).append(t)

T1 = statistics.median(tiempos["sec"])
P = [1, 2, 4, 8]
S = {1: 1.0, **{p: T1 / statistics.median(tiempos[p]) for p in P[1:]}}
f = (1 - 1 / S[4]) / (1 - 1 / 4)
amdahl = lambda p: 1 / ((1 - f) + f / p)

for p in P:
    print(f"p={p}  T={T1 / S[p]:.4f}  S={S[p]:.3f}  E={S[p] / p:.3f}  Amdahl={amdahl(p):.3f}")
print(f"f = {f:.3f}")

AZUL, NARANJA, GRIS, TINTA, TENUE = "#2a78d6", "#eb6834", "#8a8984", "#1f1f1e", "#5f5e5a"
plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11})
fig, ax = plt.subplots(figsize=(7.2, 4.6), dpi=150)
ax.axvspan(4, 8.4, color="#f1efe8", zorder=0)
ax.text(6.2, 0.55, "más hilos que núcleos físicos", ha="center", color=TENUE, fontsize=9.5)
x = [i / 10 for i in range(10, 85)]
ax.plot(P, P, ls="--", lw=2, color=GRIS, label="Ideal  S(p) = p")
ax.plot(x, [amdahl(v) for v in x], lw=2, color=NARANJA, label=f"Amdahl con f = {f:.3f}".replace(".", ","))
ax.plot(P, [S[p] for p in P], lw=2, color=AZUL, marker="o", ms=8,
        markeredgecolor="white", markeredgewidth=2, label="Medido (mediana de 7)", zorder=5)
for p in P[1:]:
    ax.annotate(f"{S[p]:.2f}".replace(".", ","), (p, S[p]), textcoords="offset points",
                xytext=(0, -18), ha="center", color=TINTA, fontsize=10)
ax.set_xticks(P)
ax.set_xlim(0.7, 8.4)
ax.set_ylim(0, 8.4)
ax.set_xlabel("Número de hilos p", color=TINTA)
ax.set_ylabel("Speedup S(p)", color=TINTA)
ax.grid(axis="y", color="#e6e4dd", lw=1)
for lado in ("top", "right"):
    ax.spines[lado].set_visible(False)
for lado in ("left", "bottom"):
    ax.spines[lado].set_color("#c9c7bf")
ax.tick_params(colors=TENUE)
ax.legend(frameon=False, loc="upper left")
fig.tight_layout()
fig.savefig(AQUI.parent / "evidencias" / "speedup.png")
