# Métricas — tracking semanal (fix de B7)

> El research de Semana 1 quedó estático y nadie midió nada después. Esta
> carpeta arregla eso: **una fila por producto × plataforma × semana** en
> `metricas.csv`.

## Cómo llenarla

Una vez por semana (domingo, 10 minutos):

| Campo | De dónde sale |
|---|---|
| `fecha` | el domingo de cierre, formato `2026-06-14` |
| `producto` | `fitness_tracker` / `sfx_guitar` / `overlay_rock` / … |
| `plataforma` | `etsy` / `gumroad` / `itch` / `pinterest` |
| `vistas` | Etsy Stats · Gumroad Analytics · itch Analytics |
| `favoritos` | favs/hearts/collections de la plataforma |
| `conversiones` | ventas de la semana |
| `ingreso_usd` | neto de la semana (después de fees) |
| `precio` | precio vigente esa semana (para detectar efecto de cambios) |
| `fuente_trafico` | dominante según la plataforma: `search` / `pinterest` / `reddit` / `direct` |
| `nota` | qué cambiaste esa semana (tags, precio, pin nuevo) — sin esto no se aprende nada |

## Reglas

1. **Validar antes de construir** (regla de oro de `OPORTUNIDADES.md` §5):
   ningún SKU nuevo sin 30 min de chequeo de demanda documentado en
   `VALIDACION.md`.
2. **Decidir con 2-3 semanas de datos, no con una.** Igual que el peso en el
   tracker: tendencia, no ruido diario.
3. Si una fila tiene `vistas` pero 0 `conversiones` 3 semanas seguidas →
   problema de listing (precio/copy/fotos). Si no tiene ni vistas → problema
   de demanda o SEO.
