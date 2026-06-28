# Perfiles de redes — pack de configuración (copy + assets listos)

> El agente configuró lo que el navegador controlado le permitió; el resto choca
> con límites duros (abajo). Acá está TODO para que lo cierres en ~3 min por red.

## Por qué no quedó 100% automático (límites reales encontrados)
1. **Reddit**: el navegador controlado bloquea reddit.com ("not allowed due to
   safety restrictions"). No se puede operar desde el agente.
2. **Subir imágenes**: el navegador solo acepta archivos "compartidos con la
   sesión" → rechaza `icono.png` y los banners locales. Las fotos/banners las
   subís vos (es 1 clic por slot).
3. **Screenshots de la extensión fallando** → no se puede manejar a ciegas la UI
   visual de IG/YouTube Studio con seguridad.

## Assets (ya generados, listos para subir)
- **Foto de perfil (las 3 redes):** `icono.png` (1254×1254)
- **Banner YouTube:** `branding/yt_banner_2560x1440.png`
- **Banner Reddit:** `branding/reddit_banner_1920x384.png`
- *(Instagram no usa banner.)*

---

## YouTube — studio.youtube.com → Personalización
**Estado:** ✅ nombre **RiffStream** y **descripción** ya cargados/publicados por el agente.
Falta (lo hacés vos):
- Pestaña **Imágenes**:
  - Foto de perfil → subí `icono.png`
  - Banner → subí `branding/yt_banner_2560x1440.png`
  - (Opcional, marca de agua → `icono.png`)
- Pestaña **Información básica → Enlaces** (agregá 3):
  - `itch.io` → https://riffstream.itch.io
  - `Gumroad` → https://jeiriz.gumroad.com
  - `Etsy` → (tu shop)
- **Publicar**.

## Reddit — reddit.com/settings/profile (lo hacés vos entero)
- **Display name:** `RiffStream`
- **About / bio:**
  ```
  A guitarist who codes. Real-guitar stream alerts (clean/overdrive/fuzz) for
  Twitch & OBS, plus spreadsheets that actually do the thinking. itch · Gumroad · Etsy.
  ```
- **Avatar** → `icono.png`
- **Banner** → `branding/reddit_banner_1920x384.png`

## Instagram — perfil → Editar perfil (lo hacés vos)
- **Nombre:** `RiffStream`
- **Bio:**
  ```
  🎸 Real-guitar stream SFX
  📊 A fitness tracker that coaches you back
  Made by a guitarist who codes ↓
  ```
- **Sitio web:** https://riffstream.itch.io  *(cambialo por tu landing de GitHub Pages cuando la publiques)*
- **Foto de perfil** → `icono.png`

---

## Texto de YouTube (por si querés re-pegarlo)
**Descripción del canal:**
```
RiffStream - real-guitar stream SFX and smart fitness tools, made by a guitarist
who codes. Stream alerts played on a real electric guitar (boutique overdrive +
germanium fuzz) for follows, donations and raids, plus an adaptive fitness tracker
for Excel & Google Sheets that reads your weight trend and coaches you back.
Get everything: itch.io, Gumroad and Etsy.
```

> Cuando publiques la landing (GitHub Pages), usá esa URL única en el campo "web"
> de cada bio en lugar de los links sueltos.
