# Roadmap — Semanas 3 a 5 (y qué quedó adelantado)

> Mapa maestro de qué hacer cada semana, qué ya está listo y qué depende de
> vos. La idea: que cuando te sientes a trabajar, no tengas que pensar qué
> sigue — solo ejecutar. Tiempo objetivo: 2-4 h/semana.

---

## 📍 Dónde estás parado

- ✅ **Semana 1** completa (research + setup).
- ✅ **Semana 2** completa salvo grabar el audio (requiere tu guitarra).
- 🎁 **Adelantado** (trabajo de Claude, ya en el repo): listings de Pack 2
  (Gym) y Pack 3 (Moto), biblia de marca, SEO, marketing, soporte, y el
  pipeline de Figma extendido para generar los packs nuevos.

---

## 🟢 Lo único bloqueante (solo vos)

1. **Grabar 3 alertas de audio** (guitarra → MiniFuse → Audacity → MP3).
   Ver README §4.4. Esto desbloquea el ZIP final del Pack 1.

Todo lo demás de abajo ya tiene el material preparado.

---

## 📅 Semana 3 — Lanzamiento Pack 1 (Rock)

**Objetivo:** primer listing activo + primeras visitas. ~3 h.

1. Grabá el audio (punto bloqueante de arriba) y rehacé el ZIP.
2. Publicá el Pack 1 en Etsy siguiendo `Semana3_Lanzamiento.md` (paso a paso,
   campo por campo). El copy y los 8 mockups ya están listos.
3. Configurá **una sola vez** la política de tienda y el mensaje automático
   (de `Etsy_Listing.md`). Aplica a todos los packs futuros.
4. Pineá los primeros 15 pins de `marketing/Pinterest_Calendario.md`
   (2-3/día, no todos juntos).
5. Posteá en Reddit el POST 1 y el POST 3 de `marketing/Reddit_Posts.md`
   (en días distintos, leyendo reglas de cada sub).

**✓ Hecho cuando:** Pack 1 visible en Etsy, ZIP con audio descargable, pins y
posts iniciales arriba.

---

## 📅 Semana 4 — Pack 2 (Gym) + optimización

**Objetivo:** segundo listing + primeros ajustes de SEO. ~4 h.

1. Generá los assets del Pack 2 con el plugin de Figma extendido
   (`riffstream-plugin-packs/` — corré el plugin, elegí Gym). Exportá los PNG.
2. Importá los íconos SVG de `packs/Pack2_Gym/svg/icons/` a Figma, ajustá si
   querés, exportá PNG 256×256.
3. Grabá (o reutilizá) 3 alertas para el Pack Gym. Podés usar las mismas del
   Pack 1 si querés ir rápido — son el mismo diferenciador.
4. Generá los mockups con `Mockups_Etsy/build_pack_mockups.ps1` (necesita
   ImageMagick instalado — ver nota al pie).
5. Publicá el Pack 2 con `packs/Pack2_Gym/Listing_Gym.md` + tags de
   `seo/Keywords_Tags.md`.
6. Primer chequeo de SEO del Pack 1: en eRank, revisá qué keywords traen
   impresiones y ajustá 2-3 tags (ver `seo/Keywords_Tags.md` §5).
7. Pins 16-25 de Pinterest + POST 4 de Reddit (Gym).

**✓ Hecho cuando:** Pack 2 publicado, Pack 1 con SEO ajustado, marketing al día.

---

## 📅 Semana 5 — Bundle + Pack 3 (Moto, opcional) + análisis

**Objetivo:** subir ticket promedio y leer resultados. ~3 h.

1. Si Rock + Gym ya tienen alguna venta/reseña, creá el **Bundle**
   (`marketing/Bundle_Listing.md`) — listing dúo Rock+Gym a $18.
2. **Pack 3 (Moto)** queda listo para publicar (`packs/Pack3_Moto/`), pero la
   demanda de moto es baja (README). Publicalo solo si querés ampliar catálogo;
   no es prioridad de ingresos.
3. **Análisis:** en Etsy Stats mirá qué listing tiene mejor conversión.
   Duplicá lo que funciona (más pins de ese estilo, variaciones del pack).
4. Pins 26-30 + reciclado con títulos nuevos.

**✓ Hecho cuando:** bundle activo, sabés cuál pack rinde mejor, catálogo de
2-3 packs + bundle.

---

## 🔭 Más allá (Meses 2-5 — del README)

- Catálogo de 5-6 packs, variaciones del pack ganador.
- Primer pack "premium" (más piezas, $18-25).
- Explorar Booth.pm además de Etsy.
- Meta: **$100 USD/mes**.

---

## 🗂️ Índice de archivos del proyecto

| Archivo | Qué es |
|---|---|
| `README.md` | Plan general 5 semanas + estado. |
| `BRAND.md` | Biblia de marca (paleta, fuentes, voz, líneas). |
| `Etsy_Listing.md` | Listing Pack 1 Rock (+ política y bienvenida globales). |
| `Semana3_Lanzamiento.md` | Checklist de publicación Pack 1 + Pinterest/Reddit. |
| `Roadmap_Semanas_3-5.md` | Este archivo. |
| `packs/Pack2_Gym/` | Listing + SVG del Pack Gym. |
| `packs/Pack3_Moto/` | Listing + 8 íconos SVG del Pack Moto. |
| `seo/Keywords_Tags.md` | Tag banks y estrategia SEO. |
| `marketing/` | Pinterest, Reddit, Bundle. |
| `soporte/Plantillas_Mensajes.md` | Respuestas al comprador. |
| `riffstream-plugin/` | Plugin Figma Pack 1 (original, tuyo). |
| `riffstream-plugin-packs/` | Plugin Figma multi-pack (Gym + Moto). |
| `Mockups_Etsy/` | Mockups + scripts de build. |

---

> **Nota — ImageMagick:** ✅ INSTALADO (portable 7.1.2-24 Q16 x64) en
> `C:\Users\Juan\Apps\ImageMagick\` y agregado al PATH de usuario. `magick`
> funciona desde cualquier shell nuevo. Es portable (sin instalador, sin
> admin): para desinstalar, borrá esa carpeta y sacá la entrada del PATH.
> Los scripts de mockups ya lo autodetectan.
