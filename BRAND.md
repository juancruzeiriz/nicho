# RiffStream — Biblia de Marca

> Documento de referencia para que TODOS los packs se vean y suenen como la
> misma marca. Cuando diseñes un pack nuevo o escribas un listing, volvé acá
> primero. La consistencia es lo que convierte 4 productos sueltos en una
> tienda que la gente reconoce.

---

## 1. Quiénes somos

**RiffStream** es una tienda de Etsy de assets para streamers hispanohablantes.
El diferenciador que nadie más tiene: **audio real grabado con guitarra y
pedalera boutique**. Cada pack incluye alertas de sonido reales, no loops
genéricos de banco.

Los tres pilares de identidad (todos personales, difíciles de copiar):
1. **Rock / guitarra** — audio real, estética metalera limpia.
2. **Gym / fitness** — conocimiento real de entrenamiento y cultura de gimnasio.
3. **Moto** — cultura motera desde adentro (Jawa RVM 250, mecánica EFI).

El audio de guitarra es el hilo conductor: aparece como bonus en los tres
nichos. Es lo que une la marca.

---

## 2. Arquitectura de productos (líneas)

Una sola tienda (**RiffStream**), tres líneas de pack que comparten el mismo
ADN visual pero cambian de acento de color y de iconografía:

| Línea | Nicho | Acento de color | Íconos clave | Estado |
|---|---|---|---|---|
| **RiffStream Rock** | guitar/rock overlay | Rojo eléctrico `#E63946` | púa, jack, amplificador, EQ | ✅ Pack 1 listo |
| **RiffStream Iron** (Gym) | gym/fitness overlay | Naranja energía `#F4A259` | mancuerna, barra, cronómetro, llama | 📝 Pack 2 — listing + SVG listos |
| **RiffStream Ruta** (Moto) | motorcycle overlay | Ámbar/acero `#F4A259` + `#8D99AE` | casco, velocímetro, llave, cadena | 📝 Pack 3 — listing + SVG listos |

> Mantener el mismo layout base (marco de cámara, barra inferior, posición de
> redes) entre líneas. Solo cambian color de acento + íconos + textos. Eso
> hace que el catálogo se vea coherente y acelera muchísimo el diseño.

---

## 3. Paleta de color (hex oficiales)

### Base (común a todos los packs)
| Rol | Hex | Uso |
|---|---|---|
| Carbón profundo | `#0F0F12` | Fondos de pantallas full (Starting/BRB/Offline) |
| Carbón medio | `#1A1A1D` | Cards, paneles, superficies |
| Carbón claro | `#26262B` | Bordes sutiles, separadores |
| Blanco roto | `#F1FAEE` | Texto principal |
| Gris texto | `#F1FAEE` al 60-AA% | Texto secundario, captions |

### Acentos por línea
| Línea | Acento primario | Acento secundario |
|---|---|---|
| Rock | `#E63946` (rojo eléctrico) | `#F4A259` (naranja) |
| Gym/Iron | `#F4A259` (naranja energía) | `#E63946` (rojo PR) |
| Moto/Ruta | `#F4A259` (ámbar) | `#8D99AE` (acero) |

> Regla: **un solo acento dominante por pieza**. El segundo se usa con
> moderación (un dato, un highlight). Nunca tres acentos peleando.

---

## 4. Tipografías

| Rol | Fuente | Fallback web/SVG | Dónde |
|---|---|---|---|
| Títulos / display | **Bebas Neue** | Bahnschrift, Oswald, Arial Narrow | "RIFFSTREAM", "EMPEZAMOS PRONTO" |
| Texto / paneles | **Inter** | Arial, Segoe UI | Captions, nombres de red, cuerpo |

Ambas gratuitas en Google Fonts. En los SVG se referencia Bebas Neue con
fallback a Bahnschrift/Arial Narrow para que rendericen aunque la fuente no
esté instalada.

---

## 5. Voz y tono (copy)

- **Idioma:** español rioplatense (Argentina). Voseo siempre: *vos, tenés,
  cargás, llevás, escribime*. Nunca tuteo (*tienes, llevas*).
- **Registro:** directo, canchero, sin marketing inflado. Hablás de streamer
  a streamer, no de empresa a cliente.
- **Largo:** frases cortas. Bullets antes que párrafos. El comprador escanea.
- **Emojis:** sí, con moderación y temáticos (🎸🤘 rock, 💪🔥 gym, 🏍️🛣️ moto).
  1-2 por bloque, no decoración constante.
- **El diferenciador SIEMPRE presente:** mencionar el audio real de guitarra
  en cada listing. Es la razón por la que te eligen sobre un competidor de $4.

### Frases-firma (reutilizables)
- Cierre rock: *"¡Que suene fuerte!"* 🔥🎸
- Cierre gym: *"¡A romperla en vivo!"* 💪
- Cierre moto: *"¡Buenos kilómetros y buenos streams!"* 🏍️
- Soporte: *"¿Dudas? Escribime, respondo rápido."*

---

## 6. Estructura estándar de un pack

Todo pack RiffStream incluye lo mismo (cambia el tema visual):

1. **1 Overlay principal** 1920×1080 transparente (marco de cámara + barra inferior + redes).
2. **3 Pantallas full HD** opacas: Empezamos Pronto / Ya Vuelvo / Offline.
3. **3 Paneles** de perfil: Discord, Instagram/Redes, Siguiente Stream.
4. **8 íconos** temáticos (PNG 256×256 + SVG).
5. **3 alertas de audio** de guitarra real: limpia / overdrive / fuzz.
6. **Guía de instalación OBS** en español (`LEEME_Primero.txt`).

**Precio de salida:** $12 USD. Subir a $18 tras 5-10 ventas con reseñas.
**Bundle 3 packs:** $28-30 USD (ver `marketing/Bundle_Listing.md`).

---

## 7. Checklist de coherencia (antes de publicar cualquier pack)

- [ ] ¿Usa la paleta base + el acento correcto de su línea?
- [ ] ¿Bebas Neue en títulos, Inter en texto?
- [ ] ¿Mismo layout base que el Pack 1 (marco, barra, redes)?
- [ ] ¿El listing menciona el audio real de guitarra?
- [ ] ¿Voseo rioplatense en todo el copy?
- [ ] ¿13 tags en inglés, todos ≤20 caracteres?
- [ ] ¿Título entre 120-140 caracteres?
- [ ] ¿Mockups con la marca de agua "RIFFSTREAM" abajo a la derecha?
