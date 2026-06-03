# Semana 3 — Lanzamiento de RiffStream en Etsy

> Guía paso a paso para publicar el primer pack y traer las primeras visitas.
> Todo el copy ya está escrito (`Etsy_Listing.md`) y los mockups ya están
> generados (`Mockups_Etsy/`). Esto es ejecución pura: ~3 horas en total.

---

## 0. Pre-requisito (lo único que falta hacer vos)

Antes de publicar tenés que **grabar las 3 alertas de audio** (ver sección 4.4
del README — guitarra → MiniFuse 1 → Audacity). Una vez exportados los MP3:

1. Copialos a `D:\proyectos-personales\nicho\RiffStream_Pack\05_Alertas_Audio\`
   con estos nombres exactos:
   - `alert-limpia.mp3`
   - `alert-overdrive.mp3`
   - `alert-fuzz.mp3`
2. Rehacé el ZIP. En PowerShell, parado en la carpeta `nicho`:
   ```powershell
   Compress-Archive -Path .\RiffStream_Pack\* -DestinationPath .\RiffStream_Pack.zip -Force
   ```
3. Verificá que el ZIP pese más que los 144 KB originales (señal de que los
   audios entraron).

> Sin este paso podés igual publicar el listing, pero el ZIP no tendría el
> diferenciador de audio. Recomendado: grabar primero.

---

## 1. Publicar el listing en Etsy (~20 min)

Entrá a **Shop Manager › Listings › Add a listing** y completá con el copy de
`Etsy_Listing.md`:

| Campo de Etsy | De dónde sacarlo |
|---|---|
| **Photos** | Subí las 8 imágenes de `Mockups_Etsy/` en orden (01 → 08). La 01_Portada va primera. |
| **Title** | El título principal (134 caracteres) de `Etsy_Listing.md`. |
| **About › Who made it** | "I did" |
| **About › What is it** | "A finished product" |
| **About › When** | "Made to order" o el año actual. |
| **Category** | Arte y coleccionables › Diseño y plantillas › Plantillas digitales. |
| **Type** | **Digital** (esto habilita la descarga automática). |
| **Description** | Pegá el bloque DESCRIPCIÓN completo. |
| **Price** | **$12 USD** (precio de salida del README). |
| **Quantity** | 999 (es digital, no se agota). |
| **Tags** | Los **13 tags en inglés** de `Etsy_Listing.md`, uno por campo. |
| **Digital files** | Subí `RiffStream_Pack.zip` (con los audios ya adentro). |

Luego, en **Settings › Policies**:
- Pegá la **POLÍTICA DE TIENDA** de `Etsy_Listing.md`.
- En **mensaje automático al comprador**, pegá el **MENSAJE DE BIENVENIDA**.

**Antes de "Publish", revisá:**
- [ ] Tipo = Digital y el ZIP está subido.
- [ ] 8 fotos en orden, la portada primero.
- [ ] 13 tags cargados (Etsy te deja exactamente 13).
- [ ] Precio $12.
- [ ] Título y descripción sin caracteres raros.

→ **Publish.** El listing queda activo al instante.

---

## 2. Pinterest — tráfico orgánico (~40 min)

Con la cuenta de negocio (creada en Semana 1):

1. Creá un **tablero** llamado "Stream Overlays & Twitch Setup".
2. **Pineá las 8 imágenes** de `Mockups_Etsy/` como pins separados.
3. Para cada pin:
   - **Título del pin** (usá variaciones, no repitas el mismo): ej.
     "Overlay de Twitch Rock con Alertas de Guitarra Real", "Pack de Stream
     para Guitarristas — OBS", "Pantallas Starting Soon / BRB / Offline Rock".
   - **Descripción**: 1-2 frases + keywords en inglés y español
     (twitch overlay, stream pack, guitar streamer, overlay español).
   - **Link de destino**: la URL de tu listing de Etsy.
4. Frecuencia recomendada: **2-3 pins por día** durante la primera semana
   (no los 8 de golpe — Pinterest premia la constancia).

---

## 3. Reddit — 2 posts (~30 min)

⚠️ **Regla de oro:** Reddit odia el spam. No pegues el link de Etsy directo en
el cuerpo. Mostrá el trabajo, sumá valor, y dejá el link solo si el sub lo
permite o si alguien lo pide en comentarios. Leé las reglas de cada subreddit
antes de postear.

### Post A — subreddit en español (r/Twitch_es, r/streamers, r/Twitch)

**Título:**
> Hice un pack de overlays para streamers rockeros/guitarristas — con alertas
> de audio grabadas con guitarra real 🎸

**Cuerpo (formato "mostrar trabajo", no venta):**
> Soy guitarrista y me cansé de los overlays genéricos para Twitch. Armé un
> pack con estética rock (overlay, 3 pantallas, paneles e íconos) y, lo que no
> vi en ningún lado, **3 alertas de sonido grabadas con mi guitarra real**
> (limpia, overdrive y fuzz). Les dejo unos previews acá 👇 ¿Qué le agregarían?
> ¿Sirve algo así para sus canales?

(Adjuntá 2-3 mockups: la portada, la de audio y una pantalla.)

### Post B — subreddit de diseño/feedback (r/Twitch, r/ObsProject, r/NewTubers)

**Título:**
> Feedback: diseñé overlays con identidad rock + alertas de guitarra real,
> ¿se ven profesionales?

**Cuerpo:** pedí feedback genuino sobre el diseño. La gente que comenta
después suele preguntar dónde conseguirlo → ahí sí pasás el link.

---

## 4. Seguimiento (primeros 7 días)

- Revisá **Etsy Stats** cada 2 días: visitas, favoritos, conversión.
- Si tenés muchas visitas pero **cero ventas** → puede ser el precio o las
  fotos. Probá mejorar la portada.
- Si tenés **pocas visitas** → es SEO/tags. Revisá qué keywords traen tráfico
  en eRank y ajustá tags.
- Primera venta con buena reseña → en Semana 4 subís el precio a **$18**.

---

## ✓ Cómo sé que completé la Semana 3

- [ ] Listing publicado y visible en Etsy con las 8 fotos.
- [ ] ZIP descargable con los 3 audios adentro.
- [ ] 8 pins en Pinterest enlazando al listing.
- [ ] 2 posts en Reddit publicados.
- [ ] Stats de Etsy registrando las primeras visitas.
