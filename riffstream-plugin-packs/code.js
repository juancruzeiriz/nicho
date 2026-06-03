// ============================================================================
//  RiffStream Packs — generador multi-pack para Figma
// ----------------------------------------------------------------------------
//  Versión generalizada del plugin original (riffstream-plugin/code.js).
//  Genera overlay + 3 paneles + 3 pantallas para CADA pack listado en BUILD,
//  cada uno en su propia fila, con su color de acento e identidad.
//
//  Cómo usar:
//   1. Editá la constante BUILD de abajo con los packs que quieras generar.
//   2. En Figma: Plugins > Development > Import plugin from manifest...
//      y elegí riffstream-plugin-packs/manifest.json.
//   3. Corré el plugin. Cada pieza queda como Frame editable; exportás PNG.
//
//  El plugin original (Pack 1 Rock) sigue intacto y funcionando aparte.
// ============================================================================

var CARBON = { r: 0.102, g: 0.102, b: 0.114 }; // #1A1A1D base oscura
var GRAFITO = { r: 0.149, g: 0.149, b: 0.169 };
var ROJO = { r: 0.902, g: 0.224, b: 0.275 };   // #E63946
var COBRE = { r: 0.957, g: 0.635, b: 0.349 };  // #F4A259
var ACERO = { r: 0.553, g: 0.600, b: 0.682 };  // #8D99AE
var BLANCO = { r: 0.945, g: 0.980, b: 0.933 }; // #F1FAEE

// --- Definición de cada pack (acento, textos, marca) ------------------------
var PACKS = {
  rock: {
    label: "Rock", brand: "RIFFSTREAM", accent: ROJO, accent2: COBRE,
    panels: [
      ["DISCORD", "discord gg riffstream"],
      ["INSTAGRAM", "arroba riffstream"],
      ["PROXIMO STREAM", "Vie 21 00"]
    ],
    screens: [
      ["RIFFSTREAM", "EMPEZAMOS PRONTO"],
      ["YA VUELVO", "BE RIGHT BACK"],
      ["OFFLINE", "EL STREAM TERMINO"]
    ]
  },
  gym: {
    label: "Gym", brand: "RIFFSTREAM IRON", accent: COBRE, accent2: ROJO,
    panels: [
      ["DISCORD", "discord gg riffstream"],
      ["INSTAGRAM", "arroba riffstream"],
      ["PROXIMO STREAM", "Lun 20 00"]
    ],
    screens: [
      ["RIFFSTREAM", "EMPEZAMOS PRONTO"],
      ["YA VUELVO", "PAUSA ENTRE SERIES"],
      ["OFFLINE", "NOS VEMOS EN LA PROXIMA"]
    ]
  },
  moto: {
    label: "Moto", brand: "RIFFSTREAM RUTA", accent: COBRE, accent2: ACERO,
    panels: [
      ["DISCORD", "discord gg riffstream"],
      ["INSTAGRAM", "arroba riffstream"],
      ["PROXIMO STREAM", "Sab 15 00"]
    ],
    screens: [
      ["RIFFSTREAM", "ARRANCAMOS PRONTO"],
      ["YA VUELVO", "PARADA TECNICA"],
      ["OFFLINE", "BUENOS KILOMETROS"]
    ]
  }
};

// --- Qué packs generar (editá esta lista) -----------------------------------
var BUILD = ["gym", "moto"];

// --- Altura de banda por pack (overlay 1080 + aire) -------------------------
var BAND = 1320;

function solid(c, a) {
  if (a === undefined) a = 1;
  return [{ type: "SOLID", color: c, opacity: a }];
}

function makeText(content, size, color, family, style) {
  if (!family) family = "Inter";
  if (!style) style = "Bold";
  return figma.loadFontAsync({ family: family, style: style })
    .then(function () {
      var t = figma.createText();
      t.fontName = { family: family, style: style };
      t.characters = content;
      t.fontSize = size;
      t.fills = solid(color);
      return t;
    })
    .catch(function () {
      return figma.loadFontAsync({ family: "Inter", style: "Bold" }).then(function () {
        var t = figma.createText();
        t.fontName = { family: "Inter", style: "Bold" };
        t.characters = content;
        t.fontSize = size;
        t.fills = solid(color);
        return t;
      });
    });
}

function rect(parent, x, y, w, h, fill, radius, opacity) {
  if (!radius) radius = 0;
  if (opacity === undefined) opacity = 1;
  var r = figma.createRectangle();
  r.resize(w, h);
  r.x = x;
  r.y = y;
  r.fills = solid(fill, opacity);
  if (radius) r.cornerRadius = radius;
  parent.appendChild(r);
  return r;
}

function buildOverlay(pack, rowY, x) {
  var overlay = figma.createFrame();
  overlay.name = pack.label + "_01_Overlay_Principal";
  overlay.resize(1920, 1080);
  overlay.fills = [];
  overlay.x = x;
  overlay.y = rowY;

  var camX = 40;
  var camY = 740;
  var cam = rect(overlay, camX, camY, 400, 300, GRAFITO, 8, 0.25);
  cam.strokes = solid(pack.accent);
  cam.strokeWeight = 3;
  rect(overlay, camX, camY - 2, 400, 2, pack.accent2, 0);
  rect(overlay, 0, 1020, 1920, 60, GRAFITO, 0, 0.85);

  return makeText("LIVE", 20, pack.accent, "Inter", "Bold").then(function (live) {
    overlay.appendChild(live);
    live.x = camX + 12;
    live.y = camY + 10;
    return overlay;
  });
}

function buildPanel(pack, name, titulo, sub, acento, rowY, x) {
  var f = figma.createFrame();
  f.name = name;
  f.resize(300, 160);
  f.fills = solid(GRAFITO);
  f.cornerRadius = 8;
  f.x = x;
  f.y = rowY;
  rect(f, 0, 156, 300, 4, acento, 0);
  rect(f, 20, 20, 48, 48, acento, 6);
  return makeText(titulo, 28, BLANCO, "Bebas Neue", "Regular").then(function (tt) {
    f.appendChild(tt);
    tt.x = 84;
    tt.y = 24;
    return makeText(sub, 16, BLANCO, "Inter", "Regular").then(function (ss) {
      f.appendChild(ss);
      ss.x = 84;
      ss.y = 64;
      ss.opacity = 0.7;
      rect(f, 280, 138, 6, 6, pack.accent2, 3);
      return f;
    });
  });
}

function buildScreen(pack, name, t1, t2, t2color, rowY, x) {
  var f = figma.createFrame();
  f.name = name;
  f.resize(1920, 1080);
  f.fills = solid(CARBON);
  f.x = x;
  f.y = rowY;
  var i = 1;
  while (i <= 6) {
    rect(f, 0, i * 154, 1920, 2, pack.accent2, 0, 0.08);
    i = i + 1;
  }
  rect(f, 0, 990, 1920, 90, GRAFITO, 0);
  return makeText(t1, 140, BLANCO, "Bebas Neue", "Regular").then(function (big) {
    f.appendChild(big);
    big.x = (1920 - big.width) / 2;
    big.y = 380;
    return makeText(t2, 48, t2color, "Bebas Neue", "Regular").then(function (sub) {
      f.appendChild(sub);
      sub.x = (1920 - sub.width) / 2;
      sub.y = 560;
      return f;
    });
  });
}

function buildPack(packKey, packIndex) {
  var pack = PACKS[packKey];
  var rowY = packIndex * BAND;
  var GAP = 120;
  var x = 0;

  // Overlay
  return buildOverlay(pack, rowY, x).then(function () {
    x = x + 1920 + GAP;
    // Paneles (3)
    var pnames = ["02_Panel_Discord", "03_Panel_Instagram", "04_Panel_Siguiente"];
    var pacc = [pack.accent, pack.accent2, pack.accent];
    var pchain = Promise.resolve();
    var pi = 0;
    function nextPanel() {
      if (pi >= pack.panels.length) return Promise.resolve();
      var idx = pi;
      var nm = pack.label + "_" + pnames[idx];
      return buildPanel(pack, nm, pack.panels[idx][0], pack.panels[idx][1], pacc[idx], rowY, x).then(function () {
        x = x + 300 + GAP;
        pi = pi + 1;
        return nextPanel();
      });
    }
    return nextPanel();
  }).then(function () {
    // Pantallas (3)
    var snames = ["05_Starting_Soon", "06_Be_Right_Back", "07_Offline"];
    var scolors = [pack.accent, pack.accent2, BLANCO];
    var si = 0;
    function nextScreen() {
      if (si >= pack.screens.length) return Promise.resolve();
      var idx = si;
      var nm = pack.label + "_" + snames[idx];
      return buildScreen(pack, nm, pack.screens[idx][0], pack.screens[idx][1], scolors[idx], rowY, x).then(function () {
        x = x + 1920 + GAP;
        si = si + 1;
        return nextScreen();
      });
    }
    return nextScreen();
  });
}

function run() {
  return figma.loadFontAsync({ family: "Inter", style: "Bold" }).then(function () {
    return figma.loadFontAsync({ family: "Inter", style: "Regular" });
  }).then(function () {
    var chain = Promise.resolve();
    var k = 0;
    function nextPack() {
      if (k >= BUILD.length) return Promise.resolve();
      var idx = k;
      return buildPack(BUILD[idx], idx).then(function () {
        k = k + 1;
        return nextPack();
      });
    }
    return nextPack();
  }).then(function () {
    figma.viewport.scrollAndZoomIntoView(figma.currentPage.children);
    figma.closePlugin("RiffStream Packs generados: " + BUILD.join(", "));
  });
}

run();
