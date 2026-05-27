# Stream Assets Business

Plan de negocio para vender packs de stream assets (overlays PNG + audio MP3) en Etsy, dirigido a streamers hispanohablantes. Diferenciadores: audio de guitarra real, cultura moto, conocimiento fitness/gym.

Ver `README.md` para el plan completo (5 semanas + visión a 5 meses).

## Estado actual

**Semana 1, Día 1** — Setup de cuentas (Etsy, eRank, Figma, Pinterest).

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
