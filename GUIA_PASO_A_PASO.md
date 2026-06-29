# Guía paso a paso (a prueba de boludos)

> Todo lo que tenés que hacer VOS, en orden, con detalle. El agente ya dejó
> hechos: la auditoría, los 7 pines, los 6 fondos de video + script de render, el
> banco de captions y la nueva primer imagen del fitness. Acá está cómo ponerlo
> a trabajar.
>
> **Cuánto tiempo:** Parte 0 a 3 son ~2 horas una sola vez. Después, ~10 min/día.
>
> **Idioma de todo lo que publicás: inglés** (mercado mundial). Vos hablás con
> los compradores en inglés; el copy ya está escrito así.

---

## Mapa rápido

| Parte | Qué | Cuándo | Tiempo |
|---|---|---|---|
| 0 | Instalar herramientas + crear cuentas | una vez | 30 min |
| 1 | Arreglar los listings (Fase 2: imagen, título, preview) | una vez | 40 min |
| 2 | Renderizar los 6 videos | una vez | 10 min |
| 3 | Grabar tus 2-3 clips de guitarra | una vez | 20 min |
| 4 | Subir contenido siguiendo el calendario | diario, 14 días | 10 min/día |
| 5 | Conseguir las primeras reseñas (outreach) | semana 1-2 | 20 min |
| 6 | Rutina semanal de métricas | cada domingo | 10 min |

Los assets están en:
- Pines: `products/Fitness_Tracker/pins/` y `products/Guitar_SFX_Pack/pins/`
- Videos (tras renderizar): `products/Guitar_SFX_Pack/video_clips/`
- Captions y calendario: `marketing/CALENDARIO_Y_CAPTIONS.md`
- Nueva primer imagen fitness: `products/Fitness_Tracker/mockups/00_first_image.png`

---

## PARTE 0 — Setup de una sola vez

### 0.1 Instalar ffmpeg (para los videos)
1. Abrí **PowerShell** (tecla Windows → escribí "powershell" → Enter).
2. Pegá esto y Enter:
   ```
   winget install --id Gyan.FFmpeg -e
   ```
   (Si no tenés winget: bajá el zip de https://www.gyan.dev/ffmpeg/builds/ →
   "ffmpeg-release-essentials.zip", descomprimí, y agregá la carpeta `bin` al PATH.)
3. **Cerrá y reabrí** PowerShell. Verificá que quedó:
   ```
   ffmpeg -version
   ```
   Si imprime una versión, listo. Si dice "no se reconoce", reiniciá la PC y probá de nuevo.

### 0.2 Cuentas que necesitás (si no las tenés)
- **Pinterest**: cuenta **Business** (gratis). Si tu cuenta RiffStream es personal,
  convertila: Configuración → "Convertir a cuenta de empresa". Da acceso a
  estadísticas (impresiones, clicks) que vas a necesitar.
- **TikTok**, **YouTube** (para Shorts) y **Instagram** (para Reels): una cuenta
  en cada una con el nombre RiffStream. El mismo MP4 va a las 3.
- **Reddit**: tu cuenta personal sirve. Sumá karma comentando un poco antes de postear.
- **YouTube (de nuevo)**: la vas a usar también para subir 1 video como "preview"
  de audio (paso 1.3).

> 📝 Las **bios de cada perfil ya están escritas** (Pinterest, TikTok, IG, X,
> YouTube, itch, Gumroad) en `marketing/BIOS_Y_YOUTUBE.md` — copiá y pegá. Ahí
> también están los títulos/descripciones de los videos de YouTube.

> ⚠️ Importante: el agente **no** crea cuentas ni sube nada por vos (login, pago y
> publicación son tuyos, por seguridad). Vos hacés clic; el material ya está listo.

---

## PARTE 1 — Arreglar los listings (Fase 2: que conviertan)

Hoy entra casi nadie, pero cuando empiece a entrar gente con la Parte 4, estos
arreglos hacen que no se vayan sin comprar.

### 1.1 Fitness Tracker — nueva primer imagen + título
**Por qué:** tu listing de fitness tuvo **0 vistas hasta dentro de Etsy**. La
portada vieja parecía "una planilla más". La nueva lidera con el coach (tu
diferenciador).

1. Entrá a tu listing del Fitness Tracker en **Etsy** (Shop Manager → Listados →
   "Macro Calculator & Weight Trend Tracker...").
2. En **Fotos**, subí `products/Fitness_Tracker/mockups/00_first_image.png` y
   **arrastralo al primer lugar** (es lo primero que ve el comprador).
3. Detrás, dejá las otras: `01_cover.png`, `02_setup.png`, `03_dashboard.png`,
   `04_workout.png`.
4. (Opcional, mejora de SEO) Reemplazá el **título** por este, que mete las
   keywords más buscadas (calorie tracker, weight loss):
   ```
   Macro & Calorie Tracker Spreadsheet | TDEE Calculator, Weight Loss Trend, Cut & Bulk Planner, Workout Log | Excel + Google Sheets
   ```
5. (Opcional) Reemplazá los **13 tags** por estos (validados con búsquedas reales
   de Etsy 2026; cada uno ≤20 caracteres):
   ```
   macro tracker, calorie tracker, macro calculator, weight loss tracker,
   tdee calculator, fitness spreadsheet, fitness tracker, workout log,
   google sheets, cut bulk planner, gym tracker, weight loss, macro counting
   ```
   > Patrón que repiten los top sellers en sus títulos: "Weight Loss & Fitness
   > Tracker ... Google Sheets | Workout, Macro + Calories". Si querés, sumá esas
   > palabras a tu descripción (no al título, ya está lleno).
6. Guardar.
7. Repetí la **primer imagen** en **Gumroad** (jeiriz.gumroad.com → Products →
   Fitness Tracker → Cover): subí `00_first_image.png` como cover principal.

> Sé honesto: el cambio de título ayuda poco mientras no haya tráfico. El motor
> de verdad es la Parte 4. Esto es para no desperdiciar las visitas que lleguen.

### 1.2 Pack SFX — revisar que esté todo
1. En **itch** e **Gumroad**, confirmá que la portada se ve bien (ya está subida).
2. El SFX se vende por el **audio** (paso 1.3) y el **video** (Parte 2-4).
3. (Opcional) En **Etsy**, los packs de alertas se buscan así — tags optimizados
   (research 2026; tu diferenciador es el tema "real guitar / rock", metelo):
   ```
   twitch alert sounds, stream alerts, twitch sound alerts, sound alerts twitch,
   twitch notifications, stream sfx, alert sounds, guitar sounds, rock stream,
   metal stream, streamlabs sounds, obs alert sounds, raid alert
   ```
   > Dato del mercado: en Etsy los packs de alertas se venden por **tema**
   > (lofi, cute, spooky, EDM...). Casi nadie tiene el tema "guitarra real / rock".
   > Ese es tu hueco: liderá con eso en el título y la primer foto.

### 1.3 Preview de audio (CLAVE para el SFX)
**Por qué:** un pack de sonidos sin algo audible no convierte. Nadie compra
sonido sin escucharlo. Solución simple que sirve en todos lados:

1. Renderizá los videos primero (Parte 2). Vas a usar uno como preview.
2. Subí **`alert-fuzz-1.mp4`** a **YouTube como "Oculto/Unlisted"** (no hace
   falta que sea público). Copiá el link.
3. Pegá ese link:
   - En **itch**: editá el proyecto → campo **"Trailer/Video"** (o pegalo en la
     descripción). Así aparece un reproducible en la página.
   - En **Gumroad**: en la descripción del producto, pegá el link de YouTube
     (Gumroad lo embebe solo).
4. Bonus: ese mismo video ya es contenido para TikTok/Shorts/Reels (Parte 4).

---

## PARTE 2 — Videos: YA ESTÁN RENDERIZADOS ✅

Los 6 MP4 verticales (1080×1920, con la onda animada) **ya están hechos y
verificados** en `products/Guitar_SFX_Pack/video_clips/` (los rendericé yo con tu
ffmpeg). **No tenés que hacer nada acá** — andá directo a subirlos (Parte 4.2).

¿Querés regenerarlos (cambiaste un hook o grabaste audio nuevo)?
1. Editá la lista `CLIPS` en `products/Guitar_SFX_Pack/build_video_clips.py`.
2. Corré: `python products/Guitar_SFX_Pack/build_video_clips.py`
   (regenera fondos + MP4 directamente, ffmpeg ya está).

---

## PARTE 3 — Grabar tus 2-3 clips auténticos (tu moat)

**Por qué:** los videos de waveform sirven para volumen, pero lo que un
competidor genérico NO puede copiar es que hay una persona real con una guitarra
boutique. Eso es lo que más convierte en el ángulo guitarra. No hace falta que
salga tu cara.

**Setup (10 min):**
1. Celular en vertical (9:16), apoyado o en trípode, plano cerrado a tus **manos +
   guitarra + pedal** (el Artemis overdrive y el fuzz germanio en cuadro).
2. Luz de una ventana de costado. Grabá el sonido directo del ampli (que se
   escuche el tono real).

**Los 3 clips (8-15 seg cada uno):**
- **Clip 1 (fuzz/raid):** tocás el riff fuzz. Texto sugerido al subir:
  `POV: your raid alert is a real guitar, not a synth preset 🎸`
- **Clip 2 (clean→overdrive):** mostrás el contraste pisando el pedal.
  `3 tones for 3 stream moments. Which one's your raid alert?`
- **Clip 3 (el pedal, opcional):** primer plano del pedal encendido + el sonido.
  `The fuzz that makes your raid alert hit different. Germanium, hand-wired.`

**Qué hacés con ellos:** pasalos del celular a la PC y subilos directo a
TikTok/Shorts/Reels (Parte 4). No necesitan edición. Si querés que el agente te
los empareje con el resto (subtítulos, formato), dejalos en una carpeta y avisá.

---

## PARTE 4 — Subir contenido (el motor de tráfico)

Seguí el **calendario de 14 días** que está en
`marketing/CALENDARIO_Y_CAPTIONS.md`. Ahí está, día por día, qué subir. Los
captions ya están escritos para copiar y pegar. Resumen del "cómo":

### 4.1 Pinterest (el motor del fitness)
1. Creá 2 tableros: **"Fitness & Nutrition"** y **"Stream Setup / Twitch"**.
2. Para cada pin: botón **Crear → Pin** → subí el PNG de `products/*/pins/` →
   pegá **título** y **descripción** (del archivo de captions) → en **"Enlace de
   destino"** pegá la URL del producto (la del caption) → Publicar.
3. **1 pin por día.** No subas todos juntos (Pinterest premia constancia). Hay
   **18 pines** en total (10 fitness + 8 SFX) → munición para ~2-3 semanas.
4. La descripción con keywords es lo que te hace aparecer en búsquedas; no la saltees.
5. **Atajo (carga masiva):** si querés subirlos de a muchos, ver Parte 7.2 (CSV).

### 4.2 TikTok / YouTube Shorts / Instagram Reels (el motor del SFX)
1. Subí el **mismo MP4** a las 3 plataformas.
2. Pegá el caption corto + hashtags (del archivo de captions).
3. Lo importante: que en los **primeros 2 segundos ya suene el riff**. Por eso los
   videos arrancan con el audio.
4. Ritmo: ~1 video cada 1-2 días. Mezclá los de waveform con tus clips reales.

### 4.3 Reddit (manual, sin spam)
- **r/excel**: 1 post de enseñanza (copy largo en
  `products/Fitness_Tracker/MARKETING_EN.md`). Contás cómo funciona la fórmula del
  trend; el link va en un comentario si las reglas lo permiten.
- **r/Twitch**: buscá el **hilo semanal de autopromoción** y comentá ahí (copy en
  `products/Guitar_SFX_Pack/MARKETING_EN.md`). Ofrecé un sample gratis del fuzz.
- Regla: aportá valor, nunca pegues el mismo texto en varios subs el mismo día.

---

## PARTE 5 — Conseguir las primeras reseñas (Fase 4)

**Por qué:** 0 reseñas mata la conversión. Nadie es el primero en comprar. La
solución: regalá el producto a cambio de feedback/reseña honesta.

### 5.1 A quién apuntar
- **SFX**: streamers **chicos** de Twitch/Kick (50-500 seguidores) que streameen
  rock/metal/gaming. Buscalos en Twitch por categoría, o en r/Twitch.
- **Fitness**: gente activa en r/excel, r/fitness, o conocidos que entrenen.

### 5.2 Cómo ofrecer (mensaje listo para pegar)

**Para streamers (DM o Discord):**
```
Hey! I make stream alert sounds played on a real guitar (not synth presets) -
clean/overdrive/fuzz for follows, donations and raids. I'd love to give you the
pack for free in exchange for honest feedback. No strings attached - if you like
it, a quick review would mean a lot. Want me to send it over?
```

**Para usuarios de r/excel / fitness:**
```
I built an Excel/Google Sheets fitness tracker that reads your 7-day weight trend
and tells you when to adjust calories. Happy to send it free if you'll give me
honest feedback (and a review if you find it useful). Interested?
```

### 5.3 Cómo entregar gratis
- **itch**: ya está en pay-what-you-want, pueden bajarlo en $0. Mandales el link.
- **Gumroad/Etsy**: generá un código de descuento del 100% y se lo pasás
  (Gumroad: Checkout → Discounts → New; Etsy: no permite 100%, usá itch para esto).
- Meta realista: **3-5 reseñas** en las primeras 2 semanas. Cambian todo.

---

## PARTE 6 — Rutina semanal de métricas (Fase 5)

**Cada domingo, 10 min.** Abrí cada dashboard, anotá las vistas/visitas, y sumá
una fila en `metricas/metricas.csv`. Así sabés qué funciona y qué no.

### 6.1 De dónde sacás cada número
| Plataforma | URL | Qué anotar |
|---|---|---|
| Etsy | etsy.com/your/shops/me/stats | Visitas (rango "Este mes") + por listing |
| Gumroad | gumroad.com/dashboard/sales | Views + Sales del rango |
| itch | itch.io/dashboard → Analytics | Views + Downloads |
| Pinterest | cuenta business → Estadísticas | Impresiones + Clicks salientes |

### 6.2 Formato de la fila (copiá el patrón que ya está en el CSV)
```
fecha,producto,plataforma,vistas,favoritos,conversiones,ingreso_usd,precio,fuente_trafico,nota
2026-07-05,Pack SFX,itch.io,45,0,0,0,5,short video,"subi 4 shorts esta semana"
```

### 6.3 La regla de decisión (a las 3-4 semanas)
- Si un formato (un tipo de pin / un short) trae **clicks de forma repetida** →
  hacé más de ese. Dobla la apuesta.
- Si una plataforma sigue en ~0 después de empujar de verdad → soltala o cambiá
  el ángulo.
- Recién cuando haya tráfico real y siga sin convertir, tocamos producto/precio.
  Hasta entonces, el trabajo es **traer gente**.

---

## PARTE 7 — Extras (landing + carga masiva + catálogo)

### 7.1 Publicar tu página "link-in-bio" (GitHub Pages, gratis)
Es la página con tus 2 productos (`docs/index.html`) para poner como **único
link** en las bios de TikTok/IG/X.

1. (Una vez) Antes que nada, agregá la URL del listing de Etsy del fitness:
   abrí `docs/index.html`, buscá el comentario `// <- pega aca la URL...` y pegá
   la URL del listing (el resto de los links ya está puesto).
2. Subí los cambios a GitHub:
   ```
   git add docs && git commit -m "landing link-in-bio" && git push
   ```
3. En GitHub: repo **nicho** → Settings → **Pages** → en "Branch" elegí
   `master` y carpeta **/docs** → Save. En 1-2 min te da una URL tipo
   `https://juancruzeiriz.github.io/nicho/`.
4. (Opcional) Verificá que se vea bien en el celular. Después pegá esa URL en la
   bio de TikTok, Instagram y X.

> Requiere que el repo **nicho** sea público (Settings → General → abajo de todo,
> "Change visibility"). Si no querés hacerlo público, una alternativa gratis es
> Carrd o Linktree, copiando los mismos textos/links.

### 7.2 Carga masiva de pines en Pinterest (CSV)
En vez de subir los 18 pines uno por uno:
1. Generá el CSV: `python marketing/build_pinterest_csv.py` →
   crea `marketing/pinterest_bulk.csv`.
2. **Requisito:** el repo debe ser público y los pines pusheados
   (`git add products/*/pins && git commit -m "pines" && git push`), porque el
   CSV apunta a las imágenes vía URL de GitHub.
3. En Pinterest (cuenta business) → Crear → **"Crear en bloque"/Bulk** → subí el
   CSV. Revisá y publicá.
   - Si el repo es privado, el bulk no va a poder bajar las imágenes → subí los
     pines a mano (Parte 4.1) o cambiá `RAW_BASE` en el script por otro host.

### 7.3 Catálogo bilingüe de overlays (cuando quieras, baja prioridad)
Los 3 packs de overlays (Rock/Gym/Moto) ya tienen **copy en inglés** listo en
`packs/Pack*/Listing_*_EN.md`, para reciclarlos en **itch.io** sin desarrollo
nuevo. No es foco; hacelo solo si te sobra tiempo después del motor de tráfico.

### 7.4 (Avanzado) Postear los pines por API de Pinterest — automático
Si en vez de subir a mano querés que se posteen solos:
1. Creá una app en **developers.pinterest.com** (cuenta business) con scopes
   `boards:write` y `pins:write`, y generá un access token.
2. Pegá el token en `marketing/secrets/pinterest_token.txt` (esa carpeta está
   ignorada por git — el token nunca se sube ni lo ve nadie) **o** exportá
   `PINTEREST_ACCESS_TOKEN`.
3. Probá sin postear: `python marketing/pinterest_api_post.py`
4. Postear de verdad (crea los 2 tableros si faltan y sube los 18 pines):
   `python marketing/pinterest_api_post.py --go`

> ⚠️ Solo Pinterest se automatiza así de fácil. **TikTok/Instagram** piden
> verificación de negocio + review de app; **X** cobra por la API de escritura;
> **Reddit** automatizado = shadowban. Esas cuatro van a mano — y en TikTok/IG
> conviene igual (respondés comentarios y montás trends, que es lo que da alcance).

---

## Checklist final (imprimible)

**Una vez:**
- [ ] ffmpeg instalado (`ffmpeg -version` funciona)
- [ ] Cuentas: Pinterest business, TikTok, YouTube, Instagram, Reddit
- [ ] Fitness: nueva primer imagen subida a Etsy y Gumroad (+ título/tags opcional)
- [ ] 6 videos renderizados (`render_clips.sh`)
- [ ] Preview de audio: 1 video subido a YouTube unlisted y linkeado en itch + Gumroad
- [ ] 2-3 clips de guitarra grabados
- [ ] Página link-in-bio publicada (GitHub Pages) y su URL puesta en las bios
- [ ] (Opcional) Repo público + pines pusheados → CSV de carga masiva de Pinterest

**Diario (14 días, ~10 min):**
- [ ] Seguir el calendario de `marketing/CALENDARIO_Y_CAPTIONS.md`

**Semanal (domingos):**
- [ ] Volcar métricas a `metricas/metricas.csv`

**Semana 1-2:**
- [ ] Mandar 5-10 mensajes de outreach para reseñas

> Cuando termines la primera vuelta de 14 días, avisá: miramos los números juntos
> y decidimos qué doblar. Ahí recién, si hay tráfico y no convierte, evaluamos
> ads o cambios de producto.
