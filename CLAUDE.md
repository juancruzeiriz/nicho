# Stream Assets Business

Plan de negocio para vender packs de stream assets (overlays PNG + audio MP3) en Etsy, dirigido a streamers hispanohablantes. Diferenciadores: audio de guitarra real, cultura moto, conocimiento fitness/gym.

Ver `README.md` para el plan completo (5 semanas + visión a 5 meses).

## Estado actual

**Assets de los 3 packs listos.** Rock, Gym y Moto tienen overlay + paneles +
pantallas + 8 íconos + 8 mockups generados. Rock se ensambla 100% con
ImageMagick (`Mockups_Etsy/build_pack_assets.ps1`, sin Figma); Gym/Moto salieron
del plugin de Figma. Pipeline completa en un comando: `Mockups_Etsy/build_all.ps1`
(ver `COMO_GENERAR_ASSETS.md`). También listos: 18 pines de Pinterest con imagen
real (`marketing/pins/`), branding de tienda (`branding/`) y mockup del bundle
(`marketing/Bundle_Mockup.png`).

Pendiente del lado del usuario: grabar las 3 alertas de audio (guitarra real) y
publicar los listings en Etsy.

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
