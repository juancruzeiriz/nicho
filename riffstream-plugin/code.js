const CARBON = { r: 0.102, g: 0.102, b: 0.114 };
const GRAFITO = { r: 0.149, g: 0.149, b: 0.169 };
const ROJO = { r: 0.902, g: 0.224, b: 0.275 };
const COBRE = { r: 0.957, g: 0.635, b: 0.349 };
const BLANCO = { r: 0.945, g: 0.980, b: 0.933 };

function solid(c, a) {
  if (a === undefined) a = 1;
  return [{ type: "SOLID", color: c, opacity: a }];
}

let cursorX = 0;
const GAP = 120;
function placeFrame(f, w) {
  f.x = cursorX;
  f.y = 0;
  cursorX = cursorX + w + GAP;
}

async function makeText(content, size, color, family, style) {
  if (!family) family = "Inter";
  if (!style) style = "Bold";
  const t = figma.createText();
  try {
    await figma.loadFontAsync({ family: family, style: style });
    t.fontName = { family: family, style: style };
  } catch (e) {
    await figma.loadFontAsync({ family: "Inter", style: "Bold" });
    t.fontName = { family: "Inter", style: "Bold" };
  }
  t.characters = content;
  t.fontSize = size;
  t.fills = solid(color);
  return t;
}

function rect(parent, x, y, w, h, fill, radius, opacity) {
  if (!radius) radius = 0;
  if (opacity === undefined) opacity = 1;
  const r = figma.createRectangle();
  r.resize(w, h);
  r.x = x;
  r.y = y;
  r.fills = solid(fill, opacity);
  if (radius) r.cornerRadius = radius;
  parent.appendChild(r);
  return r;
}

async function build() {
  await figma.loadFontAsync({ family: "Inter", style: "Bold" });
  await figma.loadFontAsync({ family: "Inter", style: "Regular" });

  const overlay = figma.createFrame();
  overlay.name = "01_Overlay_Principal";
  overlay.resize(1920, 1080);
  overlay.fills = [];
  placeFrame(overlay, 1920);

  const camX = 40;
  const camY = 740;
  const cam = rect(overlay, camX, camY, 400, 300, GRAFITO, 8, 0.25);
  cam.strokes = solid(ROJO);
  cam.strokeWeight = 3;
  rect(overlay, camX, camY - 2, 400, 2, COBRE, 0);
  rect(overlay, 0, 1020, 1920, 60, GRAFITO, 0, 0.85);
  const live = await makeText("LIVE", 20, ROJO, "Inter", "Bold");
  overlay.appendChild(live);
  live.x = camX + 12;
  live.y = camY + 10;

  async function panel(name, titulo, sub, acento) {
    const f = figma.createFrame();
    f.name = name;
    f.resize(300, 160);
    f.fills = solid(GRAFITO);
    f.cornerRadius = 8;
    placeFrame(f, 300);
    rect(f, 0, 156, 300, 4, acento, 0);
    rect(f, 20, 20, 48, 48, acento, 6);
    const tt = await makeText(titulo, 28, BLANCO, "Bebas Neue", "Regular");
    f.appendChild(tt);
    tt.x = 84;
    tt.y = 24;
    const ss = await makeText(sub, 16, BLANCO, "Inter", "Regular");
    f.appendChild(ss);
    ss.x = 84;
    ss.y = 64;
    ss.opacity = 0.7;
    rect(f, 280, 138, 6, 6, COBRE, 3);
    return f;
  }
  await panel("02_Panel_Discord", "DISCORD", "discord gg riffstream", ROJO);
  await panel("03_Panel_Instagram", "INSTAGRAM", "arroba riffstream", COBRE);
  await panel("04_Panel_Siguiente", "PROXIMO STREAM", "Vie 21 00", ROJO);

  async function fullscreen(name, t1, t2, t2color) {
    const f = figma.createFrame();
    f.name = name;
    f.resize(1920, 1080);
    f.fills = solid(CARBON);
    placeFrame(f, 1920);
    let i = 1;
    while (i <= 6) {
      rect(f, 0, i * 154, 1920, 2, COBRE, 0, 0.08);
      i = i + 1;
    }
    rect(f, 0, 990, 1920, 90, GRAFITO, 0);
    const big = await makeText(t1, 140, BLANCO, "Bebas Neue", "Regular");
    f.appendChild(big);
    big.x = (1920 - big.width) / 2;
    big.y = 380;
    const sub = await makeText(t2, 48, t2color, "Bebas Neue", "Regular");
    f.appendChild(sub);
    sub.x = (1920 - sub.width) / 2;
    sub.y = 560;
    return f;
  }
  await fullscreen("05_Starting_Soon", "RIFFSTREAM", "EMPEZAMOS PRONTO", ROJO);
  await fullscreen("06_Be_Right_Back", "YA VUELVO", "BE RIGHT BACK", COBRE);
  await fullscreen("07_Offline", "OFFLINE", "EL STREAM TERMINO", BLANCO);

  figma.viewport.scrollAndZoomIntoView(figma.currentPage.children);
  figma.closePlugin("RiffStream Pack 01 generado");
}

build();