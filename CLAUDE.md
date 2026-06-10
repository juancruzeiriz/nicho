# RiffStream — portfolio de productos digitales

Meta: **ingreso mensual recurrente en USD, de cualquier cliente del mundo, con
productos de bajo esfuerzo de desarrollo**, apalancando 4 ejes: programador,
músico (guitarra boutique), motos, nutrición/gym. Mercado mundial, **inglés
primero** (bilingüe después).

**La dirección vive en `OPORTUNIDADES.md`** (portfolio ranqueado de 8
oportunidades + falencias + regla validar-antes-de-construir). El `README.md`
describe el plan viejo (overlays en Etsy para hispanohablantes) — sirve como
historia y por la data de eRank, no como dirección.

## Estado actual

**En construcción (foco):** los dos primeros productos de la nueva dirección,
en `products/` — validación de demanda en `VALIDACION.md` (ambos GO).

1. **Fitness Tracker** (`products/Fitness_Tracker/`): xlsx generado por
   `build_tracker.py`, verificado con `verify_tracker.py` (lib `formulas`; en
   esta máquina no hay Excel ni LibreOffice). Listing EN listo. Canales: Etsy
   + Gumroad.
2. **Pack SFX de guitarra** (`products/Guitar_SFX_Pack/`): estructura,
   licencias, listing EN y empaquetador (`build_sfx_pack.ps1`) listos; faltan
   grabar 12 sonidos (checklist en `README_PACK.md`). Canales: itch + Gumroad
   + Etsy.

**Catálogo terminado (no foco):** los 3 packs de overlays (Rock/Gym/Moto) con
assets y mockups completos. Pipeline: `Mockups_Etsy/build_all.ps1 -Packs
rock,gym,moto` (ver `COMO_GENERAR_ASSETS.md`). Se reciclan bilingües en
itch/Booth como catálogo, sin más inversión de desarrollo.

**Métricas:** una fila por producto×plataforma×semana en `metricas/metricas.csv`.

## Convenciones del proyecto

- **Idioma:** español rioplatense (Argentina). Mantener voseo (`vos`, `tenés`, `pedile`) y evitar tuteo.
- **Tono:** directo, sin marketing inflado. El plan está pensado para ejecutarse en sesiones cortas.
- **Información personal en el README** (no tocar sin confirmar): setup de guitarra (Artemis overdrive, fuzz germanio, MiniFuse 1), moto (Jawa RVM 250-9), conocimiento fitness.

## Para Claude Code

### Permisos
- Permisos granulares en `.claude/settings.local.json` (no se versiona — preferencias locales).
- Por defecto: Edit / Write / Read / git seguros sin confirmación. Destructivos (`rm -rf`, `git push --force`, `git reset --hard`) y secretos (`.env`) bloqueados.

### Bypass total por sesión
Si necesitás una sesión sin ningún prompt de permisos (úsalo solo cuando estés haciendo tareas grandes y revisás bien al final):

```bash
claude --permission-mode bypassPermissions
```

Esto omite TODOS los prompts en esa sesión. Cuando cerrás y volvés a abrir Claude normal, vuelve al modo granular.

### Notas
- Proyecto en WSL2 sobre Windows (`/mnt/d/...`). Audio/Figma corren en Windows nativo, no dentro de WSL.
- Cuando se mencione `claude.ai` en el README se refiere a la web (Claude Pro del usuario), no a esta CLI.
