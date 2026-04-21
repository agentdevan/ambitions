const fs = await import("node:fs/promises");
const path = await import("node:path");
const { Presentation, PresentationFile } = await import("@oai/artifact-tool");

const W = 1280;
const H = 720;
const DECK_ID = "frontend-transformation-investor-deck";
const OUT_DIR = "C:\\Users\\Devan\\Documents\\GitHub\\ambitions\\docs\\presentations\\frontend-transformation-investor-deck";
const SCRATCH_DIR = path.resolve(process.env.PPTX_SCRATCH_DIR || path.join("tmp", "slides", DECK_ID));
const PREVIEW_DIR = path.join(SCRATCH_DIR, "preview");
const INSPECT_PATH = path.join(SCRATCH_DIR, "inspect.ndjson");

const COLOR = {
  ink: "#121518",
  graphite: "#2F353B",
  muted: "#6E757C",
  paper: "#F6F1E8",
  white: "#FFFFFF",
  panel: "#FFFCF6",
  line: "#D8D0C3",
  green: "#2EB67D",
  greenDark: "#1E7A57",
  gold: "#D7A23C",
  coral: "#E2765E",
  blue: "#88A7BC",
  smoke: "#EEF2F4",
  lavender: "#DAD8E8",
  navy: "#2E3A45",
};

const FONT = {
  title: "Caladea",
  body: "Lato",
  mono: "Aptos Mono",
};

const SOURCES = [
  "docs/codex/BATCH_REGISTRY.md",
  "docs/canon/Ambitions_Full_Frontend_Transformation_Program.md",
  "docs/canon/design/Ambitions_Frontend_Transformation_Execution_Classification.md",
  "docs/codex/batches/batch-39.md through batch-59.md",
];

const BATCHES = [
  {
    batch: 39,
    title: "Program canon and shell rewrite foundation",
    phase: "Foundation",
    accent: COLOR.green,
    mockup: "foundation",
    summary:
      "This batch locks the transformation into executable truth. It turns the redesign from an idea into a governed program with one canon, one design language, and one roadmap for everything that follows.",
    outcomes: [
      "Defines the official transformation playbook, named interaction systems, and design principles.",
      "Sets the rules for shell change, surface ownership, external surfaces, and cross-device continuity.",
      "Removes interpretation drift so every later batch builds toward the same premium product outcome.",
    ],
  },
  {
    batch: 40,
    title: "Shell reconsideration and navigation architecture",
    phase: "Foundation",
    accent: COLOR.green,
    mockup: "shell",
    summary:
      "This is the structural rewrite of the product shell. Ambitions gets a clearer navigation model, more coherent route ownership, and a foundation built to support the entire front-end transformation.",
    outcomes: [
      "Rebuilds top-level navigation and deep-link behavior into one coherent system.",
      "Introduces the adaptive header rail and shell-aware transition grammar.",
      "Makes every later surface redesign easier to understand, faster to enter, and harder to fragment.",
    ],
  },
  {
    batch: 41,
    title: "Design system, materials, motion engine, and controls",
    phase: "Foundation",
    accent: COLOR.green,
    mockup: "designsystem",
    summary:
      "This batch gives Ambitions one premium visual language. Typography, surfaces, motion, controls, and theming become part of a single system instead of screen-by-screen styling.",
    outcomes: [
      "Standardizes tokens for color, spacing, typography, depth, timing, and haptics.",
      "Creates the shared component set every future surface can rely on.",
      "Elevates the product from good app screens to one authored flagship interface.",
    ],
  },
  {
    batch: 42,
    title: "Global compose, search, capture, and command surface",
    phase: "Foundation",
    accent: COLOR.green,
    mockup: "command",
    summary:
      "This is the cross-app action layer. Capture, search, quick planning, recovery, and recall all converge into one elegant command experience.",
    outcomes: [
      "Introduces the contextual global compose model and quiet command sheet.",
      "Unifies fast capture, memory recall, open-object actions, and recovery shortcuts.",
      "Makes the app feel more like an operating system than a collection of disconnected screens.",
    ],
  },
  {
    batch: 43,
    title: "Today rebuild I — living hero, now state, and action model",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "today",
    summary:
      "Today becomes the flagship command center. The home experience starts prioritizing the real now, the next move, and the strongest action with far more clarity and authority.",
    outcomes: [
      "Introduces the living hero surface for now, next, and daily posture.",
      "Refocuses the home screen around one obvious best move instead of stacked utility panels.",
      "Makes the product’s most frequently used surface feel calmer, stronger, and more habit-forming.",
    ],
  },
  {
    batch: 44,
    title: "Today rebuild II — time aperture, recovery bloom, and day logic",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "todayRecovery",
    summary:
      "The Today experience becomes adaptive and reality-aware. Ambitions starts helping users recover from drift, understand time, and reshape the day without shame or complexity.",
    outcomes: [
      "Adds time aperture for understanding room, compression, and availability at a glance.",
      "Introduces recovery bloom so broken plans turn into safe next moves instead of dead ends.",
      "Upgrades day-shaping logic so the home surface feels more intelligent under real-life pressure.",
    ],
  },
  {
    batch: 45,
    title: "Goals rebuild I — direction board and horizon ladder",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "goals",
    summary:
      "Goals stops feeling like inventory and starts feeling like direction. This batch turns ambitions into a living board of priorities, momentum, and long-range structure.",
    outcomes: [
      "Rebuilds goal cards around health, pace, pressure, and strategic relevance.",
      "Introduces horizon-based structure so users can see what matters now, this week, and over time.",
      "Makes ambition feel visible and actionable instead of buried in lists.",
    ],
  },
  {
    batch: 46,
    title: "Goal intake and Strategy Composer",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "composer",
    summary:
      "Goal creation becomes strategic rather than administrative. New ambitions move through a guided, high-trust composition flow that helps users shape believable plans from day one.",
    outcomes: [
      "Turns goal intake into a premium authored flow instead of a plain form.",
      "Helps users define scope, pace, and structure before a goal enters execution.",
      "Improves the quality of every later screen by starting with stronger planning inputs.",
    ],
  },
  {
    batch: 47,
    title: "Goal Detail rebuild I — strategic chamber and path filmstrip",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "goalDetail",
    summary:
      "Each goal becomes a living strategy chamber. The product starts showing movement, phase, and next action in a way that feels dynamic, visual, and easy to trust.",
    outcomes: [
      "Introduces a richer goal detail hierarchy built around path, phase, and next movement.",
      "Adds the path filmstrip so progress feels directional instead of administrative.",
      "Creates a more premium bridge between goals, today, and weekly planning.",
    ],
  },
  {
    batch: 48,
    title: "Goal Detail rebuild II — trust whisper, correction, audit, and memory",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "trust",
    summary:
      "Trust becomes beautifully legible. Users gain a calm way to understand why the system made a call, what changed, and how to correct it without technical clutter.",
    outcomes: [
      "Introduces trust whisper, audit, contradiction review, and memory depth into Goal Detail.",
      "Turns corrections into humane product interactions rather than model management.",
      "Strengthens confidence in the intelligence layer without sacrificing calmness or restraint.",
    ],
  },
  {
    batch: 49,
    title: "Plan rebuild I — elastic week and pressure scrubber",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "plan",
    summary:
      "Weekly planning becomes a premium shaping workspace. Instead of a cramped calendar, users see room, pressure, and tradeoffs in a format that feels elegant and decisive.",
    outcomes: [
      "Introduces the elastic week view so time density expands and compresses intentionally.",
      "Makes pressure visible through a calmer planning grammar instead of dashboard clutter.",
      "Turns Plan into a strategic workspace that supports action rather than fighting it.",
    ],
  },
  {
    batch: 50,
    title: "Plan rebuild II — habits, captures, weekly review, and shaping logic",
    phase: "Core surfaces",
    accent: COLOR.gold,
    mockup: "planAdvanced",
    summary:
      "Plan becomes a true operating system for the week. Habits, captures, review loops, and advanced shaping behaviors lock into the same authored planning experience.",
    outcomes: [
      "Absorbs supporting workflows into the planning surface so the week feels unified.",
      "Adds advanced later-core behaviors like window magnetism and contained split-pane shaping states.",
      "Makes the weekly loop stronger, more believable, and more defensible as a flagship experience.",
    ],
  },
  {
    batch: 51,
    title: "Insights rebuild and reflection OS",
    phase: "Trust and reflection",
    accent: COLOR.coral,
    mockup: "insights",
    summary:
      "Insights evolves from analytics into narrative proof. Reflection becomes more human, more trustworthy, and more useful for long-term momentum.",
    outcomes: [
      "Rebuilds the reflection experience around patterns, proof, and behavior clusters.",
      "Introduces review constellation as a more premium alternative to dashboard-heavy analytics.",
      "Gives investors and users a clearer picture of how the product turns history into actionable insight.",
    ],
  },
  {
    batch: 52,
    title: "Profile rebuild, Appearance Studio, and Trust Center",
    phase: "Trust and reflection",
    accent: COLOR.coral,
    mockup: "profile",
    summary:
      "Utility surfaces become premium. Appearance, trust, sync, defaults, and system posture move into an experience that feels deliberate instead of settings-heavy.",
    outcomes: [
      "Introduces Appearance Studio for curated theming and visual personalization.",
      "Creates a calmer trust center for sync, integrations, and system status.",
      "Raises the overall product finish by making utility feel as designed as execution.",
    ],
  },
  {
    batch: 53,
    title: "Onboarding, first-run, permissions, education, and state systems",
    phase: "Trust and reflection",
    accent: COLOR.coral,
    mockup: "onboarding",
    summary:
      "The first-run experience becomes worthy of the product. New users get a calmer entry, clearer permissions, and more intentional state behavior from the beginning.",
    outcomes: [
      "Rebuilds onboarding and education around product confidence rather than setup friction.",
      "Improves loading, error, empty, and re-entry states across the transformed product.",
      "Makes early user impressions more premium, more understandable, and more conversion-friendly.",
    ],
  },
  {
    batch: 54,
    title: "External surfaces I — widgets, Live Activities, notifications",
    phase: "Ambient extension",
    accent: COLOR.blue,
    mockup: "widgets",
    summary:
      "Ambitions steps beyond the app. Widgets, Live Activities, and notifications become real product surfaces that carry the same clarity, tone, and quality as the core experience.",
    outcomes: [
      "Extends the transformed visual system into glanceable iPhone surfaces.",
      "Creates more daily visibility without relying on attention-grabbing gimmicks.",
      "Strengthens retention by making Ambitions useful before the app even opens.",
    ],
  },
  {
    batch: 55,
    title: "External surfaces II — share extension, App Intents, shortcuts, routing",
    phase: "Ambient extension",
    accent: COLOR.blue,
    mockup: "routing",
    summary:
      "External entry points become part of the operating system. Sharing, shortcuts, intents, and routing feel native, fast, and deeply integrated instead of peripheral.",
    outcomes: [
      "Lets users push ideas into Ambitions from wherever they are.",
      "Turns shortcuts and intents into serious product touchpoints, not technical extras.",
      "Improves the odds that the product becomes part of a user’s daily mental workflow.",
    ],
  },
  {
    batch: 56,
    title: "Cross-surface command, recall, and ambient coherence",
    phase: "Ambient extension",
    accent: COLOR.blue,
    mockup: "memory",
    summary:
      "The product starts acting like a real external brain. Recall, command, and handoff are unified so context follows the user across every major surface.",
    outcomes: [
      "Extends memory lens and command behavior across in-app and ambient experiences.",
      "Makes handoff between surfaces calmer, clearer, and less repetitive.",
      "Deepens the product moat by turning isolated actions into one coherent cognitive system.",
    ],
  },
  {
    batch: 57,
    title: "iPad and Mac surface architecture and first implementation",
    phase: "Multi-device",
    accent: COLOR.navy,
    mockup: "desktop",
    summary:
      "The transformation expands to larger screens. Ambitions becomes a more powerful planning and reflection environment on iPad and Mac without losing its calmness.",
    outcomes: [
      "Adapts the shell and major surfaces for deeper work on larger displays.",
      "Introduces multi-pane and keyboard-aware patterns where they add clarity.",
      "Opens the door to higher-value use cases like richer planning, review, and strategy sessions.",
    ],
  },
  {
    batch: 58,
    title: "Watch and Apple TV ambient surface architecture and first implementation",
    phase: "Multi-device",
    accent: COLOR.navy,
    mockup: "ambient",
    summary:
      "Ambitions becomes ambient and household-visible. Watch and TV extend focus, ritual, and reflection into surfaces designed for the way people actually live.",
    outcomes: [
      "Brings the product into low-friction moments of attention throughout the day.",
      "Introduces future-facing ritual, momentum, and focus touchpoints beyond the phone.",
      "Strengthens the platform story by showing Ambitions can scale as an ecosystem product.",
    ],
  },
  {
    batch: 59,
    title: "Finish-quality pass, accessibility, performance, and release polish",
    phase: "Flagship finish",
    accent: COLOR.greenDark,
    mockup: "finish",
    summary:
      "The roadmap ends with polish, accessibility, performance, and release-grade refinement. This is where the transformed product becomes singular, cohesive, and ready to be judged as a flagship experience.",
    outcomes: [
      "Tunes motion, haptics, responsiveness, and consistency across the full product.",
      "Raises accessibility and quality assurance to first-class release criteria.",
      "Turns a completed roadmap into a credible, launch-quality front-end transformation.",
    ],
  },
];

const inspect = [];

async function ensureDirs() {
  await fs.mkdir(OUT_DIR, { recursive: true });
  await fs.mkdir(SCRATCH_DIR, { recursive: true });
  await fs.mkdir(PREVIEW_DIR, { recursive: true });
}

function line(fill, width = 0) {
  return { style: "solid", fill, width };
}

function addShape(slide, geometry, left, top, width, height, fill, stroke = COLOR.line, strokeWidth = 0, rotation = 0) {
  return slide.shapes.add({
    geometry,
    position: { left, top, width, height, rotation },
    fill,
    line: line(stroke, strokeWidth),
  });
}

function addText(slide, slideNo, text, left, top, width, height, opts = {}) {
  const {
    size = 20,
    color = COLOR.ink,
    bold = false,
    face = FONT.body,
    align = "left",
    valign = "top",
    fill = "#00000000",
    stroke = "#00000000",
    strokeWidth = 0,
    role = "text",
  } = opts;
  const shape = addShape(slide, "rect", left, top, width, height, fill, stroke, strokeWidth);
  shape.text = text;
  shape.text.fontSize = size;
  shape.text.color = color;
  shape.text.bold = bold;
  shape.text.typeface = face;
  shape.text.alignment = align;
  shape.text.verticalAlignment = valign;
  shape.text.autoFit = "shrinkText";
  shape.text.insets = { left: 0, right: 0, top: 0, bottom: 0 };
  inspect.push({
    kind: "textbox",
    slide: slideNo,
    role,
    text,
    bbox: [left, top, width, height],
  });
  return shape;
}

function addPill(slide, slideNo, text, left, top, width, accent, fill = COLOR.white) {
  addShape(slide, "roundRect", left, top, width, 28, fill, accent, 1.2);
  addText(slide, slideNo, text, left + 12, top + 6, width - 24, 16, {
    size: 11,
    color: accent,
    bold: true,
    face: FONT.mono,
    align: "center",
    role: "pill",
  });
}

function addBackground(slide, slideNo, accent) {
  slide.background.fill = COLOR.paper;
  addShape(slide, "ellipse", 920, -120, 420, 420, `${accent}18`, "#00000000", 0);
  addShape(slide, "ellipse", -120, 510, 340, 340, `${accent}10`, "#00000000", 0);
  addShape(slide, "roundRect", 56, 36, 1168, 648, COLOR.panel, COLOR.line, 1.2);
  addShape(slide, "rect", 56, 36, 1168, 8, accent, "#00000000", 0);
  addText(slide, slideNo, "AMBitions front-end transformation", 74, 54, 300, 18, {
    size: 10,
    face: FONT.mono,
    color: COLOR.muted,
    bold: true,
    role: "eyebrow",
  });
}

function addSlideFooter(slide, slideNo, leftText, rightText = "Investor presentation preview") {
  addText(slide, slideNo, leftText, 74, 666, 700, 16, {
    size: 10,
    color: COLOR.muted,
    face: FONT.body,
    role: "footer-left",
  });
  addText(slide, slideNo, rightText, 964, 666, 238, 16, {
    size: 10,
    color: COLOR.muted,
    face: FONT.body,
    align: "right",
    role: "footer-right",
  });
}

function addSectionHeader(slide, slideNo, batch, accent) {
  addPill(slide, slideNo, `BATCH ${batch.batch}`, 74, 82, 102, accent, COLOR.white);
  addPill(slide, slideNo, batch.phase.toUpperCase(), 186, 82, 144, accent, COLOR.white);
  addText(slide, slideNo, batch.title, 74, 122, 600, 92, {
    size: 28,
    bold: true,
    face: FONT.title,
    color: COLOR.ink,
    role: "title",
  });
  addText(slide, slideNo, batch.summary, 74, 218, 560, 86, {
    size: 18,
    color: COLOR.graphite,
    role: "summary",
  });
}

function addOutcomeBlocks(slide, slideNo, batch, accent) {
  const baseY = 320;
  batch.outcomes.forEach((item, idx) => {
    const top = baseY + idx * 104;
    addShape(slide, "roundRect", 74, top, 560, 84, COLOR.white, COLOR.line, 1.1);
    addShape(slide, "ellipse", 92, top + 18, 46, 46, `${accent}22`, accent, 1.1);
    addText(slide, slideNo, String(idx + 1), 107, top + 29, 16, 18, {
      size: 15,
      bold: true,
      face: FONT.mono,
      color: accent,
      align: "center",
      role: "outcome-index",
    });
    addText(slide, slideNo, item, 154, top + 20, 454, 46, {
      size: 16,
      color: COLOR.ink,
      role: "outcome",
    });
  });
}

function drawPhone(slide, left, top, width, height, accent, screenFill = COLOR.smoke) {
  addShape(slide, "roundRect", left, top, width, height, COLOR.ink, COLOR.ink, 1);
  addShape(slide, "roundRect", left + 10, top + 10, width - 20, height - 20, screenFill, "#00000000", 0);
  addShape(slide, "roundRect", left + width / 2 - 54, top + 14, 108, 16, COLOR.graphite, "#00000000", 0);
  addShape(slide, "rect", left + 20, top + 48, width - 40, 4, `${accent}55`, "#00000000", 0);
  return { screenLeft: left + 20, screenTop: top + 62, screenWidth: width - 40, screenHeight: height - 96, accent };
}

function drawTablet(slide, left, top, width, height) {
  addShape(slide, "roundRect", left, top, width, height, COLOR.ink, COLOR.ink, 1);
  addShape(slide, "roundRect", left + 12, top + 12, width - 24, height - 24, COLOR.smoke, "#00000000", 0);
  return { x: left + 24, y: top + 30, w: width - 48, h: height - 54 };
}

function drawDesktop(slide, left, top, width, height) {
  addShape(slide, "roundRect", left, top, width, height, COLOR.ink, COLOR.ink, 1);
  addShape(slide, "roundRect", left + 10, top + 10, width - 20, height - 20, COLOR.smoke, "#00000000", 0);
  addShape(slide, "rect", left + width / 2 - 70, top + height + 8, 140, 10, COLOR.ink, "#00000000", 0);
  addShape(slide, "rect", left + width / 2 - 12, top + height - 10, 24, 24, COLOR.ink, "#00000000", 0);
  return { x: left + 22, y: top + 30, w: width - 44, h: height - 44 };
}

function drawWatch(slide, left, top, size) {
  addShape(slide, "rect", left + 32, top - 48, 44, 58, COLOR.graphite, "#00000000", 0);
  addShape(slide, "rect", left + 32, top + size - 10, 44, 58, COLOR.graphite, "#00000000", 0);
  addShape(slide, "roundRect", left, top, size, size, COLOR.ink, COLOR.ink, 1);
  addShape(slide, "roundRect", left + 10, top + 10, size - 20, size - 20, COLOR.smoke, "#00000000", 0);
}

function drawTV(slide, left, top, width, height) {
  addShape(slide, "roundRect", left, top, width, height, COLOR.ink, COLOR.ink, 1);
  addShape(slide, "roundRect", left + 10, top + 10, width - 20, height - 20, COLOR.smoke, "#00000000", 0);
  addShape(slide, "rect", left + width / 2 - 8, top + height - 10, 16, 24, COLOR.ink, "#00000000", 0);
  addShape(slide, "rect", left + width / 2 - 60, top + height + 10, 120, 8, COLOR.ink, "#00000000", 0);
}

function drawTinyPill(slide, left, top, width, fill) {
  addShape(slide, "roundRect", left, top, width, 14, fill, "#00000000", 0);
}

function drawMockup(slide, slideNo, batch) {
  const accent = batch.accent;
  const canvasX = 690;
  const canvasY = 92;
  const canvasW = 500;
  const canvasH = 560;
  addShape(slide, "roundRect", canvasX, canvasY, canvasW, canvasH, "#FBF8F1", COLOR.line, 1);
  addText(slide, slideNo, "Intended batch outcome", canvasX + 24, canvasY + 20, 160, 18, {
    size: 11,
    face: FONT.mono,
    bold: true,
    color: accent,
    role: "mockup-label",
  });

  const type = batch.mockup;
  if (type === "foundation") {
    addShape(slide, "roundRect", 760, 160, 260, 180, COLOR.white, COLOR.line, 1.1, -5);
    addShape(slide, "roundRect", 800, 196, 264, 178, COLOR.smoke, COLOR.line, 1.1, 4);
    addShape(slide, "roundRect", 832, 236, 250, 170, COLOR.white, accent, 2.4);
    addText(slide, slideNo, "Shell truth", 854, 254, 120, 20, { size: 12, face: FONT.mono, bold: true, color: accent, role: "mockup" });
    addText(slide, slideNo, "Design canon", 854, 284, 160, 24, { size: 22, face: FONT.title, bold: true, role: "mockup" });
    addShape(slide, "rect", 854, 324, 196, 4, `${accent}66`, "#00000000", 0);
    addShape(slide, "rect", 854, 342, 166, 4, `${accent}44`, "#00000000", 0);
    addShape(slide, "rect", 854, 360, 144, 4, `${accent}33`, "#00000000", 0);
    for (let i = 0; i < 4; i += 1) {
      drawTinyPill(slide, 854 + i * 48, 382, 38, i % 2 ? COLOR.gold : accent);
    }
    return;
  }

  if (type === "designsystem") {
    addShape(slide, "roundRect", 740, 150, 400, 360, COLOR.white, COLOR.line, 1.2);
    addText(slide, slideNo, "System tokens", 766, 174, 130, 20, { size: 12, face: FONT.mono, bold: true, color: accent, role: "mockup" });
    const swatches = [accent, COLOR.gold, COLOR.coral, COLOR.blue, COLOR.navy];
    swatches.forEach((fill, idx) => {
      addShape(slide, "roundRect", 768 + idx * 68, 214, 52, 52, fill, "#00000000", 0);
    });
    addShape(slide, "roundRect", 768, 304, 156, 48, accent, "#00000000", 0);
    addText(slide, slideNo, "Primary action", 796, 319, 100, 18, { size: 13, color: COLOR.white, face: FONT.body, bold: true, role: "mockup" });
    addShape(slide, "roundRect", 944, 304, 156, 48, COLOR.panel, accent, 1.3);
    addText(slide, slideNo, "Secondary", 990, 319, 70, 18, { size: 13, color: accent, face: FONT.body, bold: true, role: "mockup" });
    addShape(slide, "roundRect", 768, 380, 332, 92, COLOR.smoke, "#00000000", 0);
    addText(slide, slideNo, "Typography, motion, spacing, and materials all align into one premium system.", 792, 398, 282, 46, { size: 18, role: "mockup" });
    return;
  }

  if (type === "desktop") {
    const desk = drawDesktop(slide, 736, 162, 314, 194);
    addShape(slide, "roundRect", desk.x, desk.y, desk.w, 54, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", desk.x, desk.y + 64, desk.w * 0.58, 98, `${accent}16`, "#00000000", 0);
    addShape(slide, "rect", desk.x + desk.w * 0.62, desk.y + 64, desk.w * 0.38, 98, COLOR.white, "#00000000", 0);
    const tab = drawTablet(slide, 880, 384, 230, 170);
    addShape(slide, "roundRect", tab.x, tab.y, tab.w, 44, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", tab.x, tab.y + 56, tab.w, 12, `${accent}30`, "#00000000", 0);
    addShape(slide, "rect", tab.x, tab.y + 80, tab.w * 0.45, 52, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", tab.x + tab.w * 0.5, tab.y + 80, tab.w * 0.5, 52, `${COLOR.gold}30`, "#00000000", 0);
    return;
  }

  if (type === "ambient") {
    drawWatch(slide, 754, 234, 126);
    drawTV(slide, 902, 198, 230, 148);
    addShape(slide, "roundRect", 774, 256, 86, 18, `${accent}22`, "#00000000", 0);
    addShape(slide, "roundRect", 774, 286, 64, 38, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", 922, 226, 190, 16, `${accent}20`, "#00000000", 0);
    addShape(slide, "ellipse", 956, 264, 42, 42, `${COLOR.gold}70`, "#00000000", 0);
    addShape(slide, "ellipse", 1014, 248, 64, 64, `${accent}40`, "#00000000", 0);
    addShape(slide, "ellipse", 1086, 258, 30, 30, `${COLOR.coral}66`, "#00000000", 0);
    return;
  }

  if (type === "finish") {
    const p = drawPhone(slide, 758, 174, 116, 234, accent);
    addShape(slide, "roundRect", p.screenLeft, p.screenTop, p.screenWidth, 44, COLOR.white, "#00000000", 0);
    drawDesktop(slide, 902, 170, 230, 144);
    drawWatch(slide, 926, 372, 98);
    addShape(slide, "roundRect", 1040, 362, 112, 112, COLOR.white, COLOR.line, 1.1);
    for (let i = 0; i < 4; i += 1) {
      addShape(slide, "ellipse", 1064 + (i % 2) * 36, 386 + Math.floor(i / 2) * 36, 20, 20, `${accent}24`, accent, 1.3);
      addText(slide, slideNo, "✓", 1068 + (i % 2) * 36, 389 + Math.floor(i / 2) * 36, 12, 12, {
        size: 12,
        bold: true,
        face: FONT.mono,
        color: accent,
        align: "center",
        role: "mockup",
      });
    }
    return;
  }

  const phone = drawPhone(slide, 826, 126, 246, 474, accent);
  const sx = phone.screenLeft;
  const sy = phone.screenTop;
  const sw = phone.screenWidth;

  if (type === "shell") {
    addShape(slide, "roundRect", sx, sy, sw, 62, `${accent}20`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 16, sy + 18, 68, 18, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx + 100, sy + 18, 88, 18, `${accent}44`, "#00000000", 0);
    addShape(slide, "rect", sx, sy + 88, sw, 96, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", sx, sy + 198, sw, 72, `${COLOR.gold}22`, "#00000000", 0);
    addShape(slide, "rect", sx, sy + 286, sw, 88, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx + 34, sy + 390, sw - 68, 48, COLOR.ink, "#00000000", 0);
    return;
  }

  if (type === "command") {
    addShape(slide, "rect", sx, sy, sw, 280, `${accent}12`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 18, sy + 126, sw - 36, 180, COLOR.white, COLOR.line, 1);
    for (let i = 0; i < 5; i += 1) {
      addShape(slide, "roundRect", sx + 34, sy + 146 + i * 28, sw - 68, 18, i === 0 ? `${accent}22` : COLOR.smoke, "#00000000", 0);
    }
    return;
  }

  if (type === "today" || type === "todayRecovery") {
    addShape(slide, "roundRect", sx, sy, sw, 92, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 16, sy + 16, sw - 32, 22, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx + 16, sy + 50, 108, 22, `${COLOR.gold}40`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 112, sw, 72, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 196, sw, 72, `${COLOR.gold}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 282, sw, 80, COLOR.white, "#00000000", 0);
    if (type === "todayRecovery") {
      addShape(slide, "roundRect", sx + 18, sy + 382, sw - 36, 90, `${COLOR.coral}18`, COLOR.coral, 1.2);
      addShape(slide, "roundRect", sx + 34, sy + 402, 118, 20, COLOR.white, "#00000000", 0);
      addShape(slide, "roundRect", sx + 34, sy + 434, 88, 20, `${accent}40`, "#00000000", 0);
    }
    return;
  }

  if (type === "goals") {
    addShape(slide, "roundRect", sx, sy, sw, 70, `${accent}18`, "#00000000", 0);
    for (let i = 0; i < 4; i += 1) {
      const top = sy + 88 + i * 82;
      addShape(slide, "roundRect", sx, top, sw, 66, COLOR.white, "#00000000", 0);
      addShape(slide, "rect", sx + 16, top + 18, 118, 10, `${accent}32`, "#00000000", 0);
      addShape(slide, "rect", sx + 16, top + 38, 74 + i * 26, 8, i % 2 ? `${COLOR.gold}55` : `${accent}55`, "#00000000", 0);
    }
    return;
  }

  if (type === "composer") {
    addShape(slide, "roundRect", sx, sy, sw, 54, `${accent}16`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 76, sw, 112, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 204, sw, 92, `${COLOR.gold}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 314, sw, 86, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx + 22, sy + 420, sw - 44, 42, accent, "#00000000", 0);
    return;
  }

  if (type === "goalDetail" || type === "trust") {
    addShape(slide, "roundRect", sx, sy, sw, 86, `${accent}18`, "#00000000", 0);
    addShape(slide, "rect", sx + 18, sy + 108, sw - 36, 10, `${accent}30`, "#00000000", 0);
    for (let i = 0; i < 5; i += 1) {
      addShape(slide, "ellipse", sx + 18 + i * 42, sy + 136, 24, 24, i < 3 ? accent : COLOR.line, "#00000000", 0);
    }
    addShape(slide, "roundRect", sx, sy + 190, sw, 86, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 292, sw, 78, `${COLOR.gold}18`, "#00000000", 0);
    if (type === "trust") {
      addShape(slide, "roundRect", sx + 22, sy + 352, sw - 44, 108, COLOR.white, COLOR.line, 1.1);
      drawTinyPill(slide, sx + 42, sy + 374, 118, `${accent}28`);
      drawTinyPill(slide, sx + 42, sy + 406, 86, `${COLOR.coral}28`);
    }
    return;
  }

  if (type === "plan" || type === "planAdvanced") {
    addShape(slide, "roundRect", sx, sy, sw, 78, `${accent}18`, "#00000000", 0);
    for (let row = 0; row < 4; row += 1) {
      const top = sy + 96 + row * 74;
      addShape(slide, "rect", sx, top, sw, 58, row % 2 ? COLOR.white : `${COLOR.blue}12`, "#00000000", 0);
      addShape(slide, "roundRect", sx + 18 + row * 12, top + 16, 78, 18, row % 2 ? `${accent}46` : `${COLOR.gold}44`, "#00000000", 0);
      addShape(slide, "roundRect", sx + 112 + row * 10, top + 16, 56, 18, `${COLOR.coral}36`, "#00000000", 0);
    }
    if (type === "planAdvanced") {
      addShape(slide, "roundRect", sx + sw - 86, sy + 176, 70, 152, COLOR.white, COLOR.line, 1.1);
      addShape(slide, "rect", sx + sw - 72, sy + 196, 42, 10, `${accent}30`, "#00000000", 0);
      addShape(slide, "rect", sx + sw - 72, sy + 220, 42, 10, `${COLOR.gold}30`, "#00000000", 0);
      addShape(slide, "rect", sx + sw - 72, sy + 244, 42, 10, `${COLOR.coral}30`, "#00000000", 0);
    }
    return;
  }

  if (type === "insights") {
    addShape(slide, "roundRect", sx, sy, sw, 76, `${accent}18`, "#00000000", 0);
    const nodes = [
      [sx + 48, sy + 150, 62, `${accent}48`],
      [sx + 124, sy + 210, 86, `${COLOR.gold}52`],
      [sx + 62, sy + 286, 52, `${COLOR.coral}48`],
      [sx + 188, sy + 298, 48, `${COLOR.blue}50`],
      [sx + 154, sy + 138, 44, `${accent}26`],
    ];
    nodes.forEach(([x, y, d, fill]) => addShape(slide, "ellipse", x, y, d, d, fill, "#00000000", 0));
    addShape(slide, "rect", sx, sy + 392, sw, 54, COLOR.white, "#00000000", 0);
    return;
  }

  if (type === "profile") {
    addShape(slide, "roundRect", sx, sy, sw, 68, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 88, sw, 90, COLOR.white, "#00000000", 0);
    [accent, COLOR.gold, COLOR.coral, COLOR.blue].forEach((fill, idx) => {
      addShape(slide, "roundRect", sx + 18 + idx * 52, sy + 208, 34, 34, fill, "#00000000", 0);
    });
    addShape(slide, "roundRect", sx, sy + 272, sw, 74, `${COLOR.blue}14`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 364, sw, 74, COLOR.white, "#00000000", 0);
    return;
  }

  if (type === "onboarding") {
    addShape(slide, "roundRect", sx + 10, sy + 18, sw - 20, 94, `${accent}16`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 22, sy + 130, sw - 44, 116, COLOR.white, COLOR.line, 1);
    addShape(slide, "roundRect", sx + 22, sy + 264, sw - 44, 82, `${COLOR.gold}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 40, sy + 374, sw - 80, 46, accent, "#00000000", 0);
    return;
  }

  if (type === "widgets") {
    addShape(slide, "roundRect", 720, 178, 132, 132, COLOR.white, COLOR.line, 1.1);
    addShape(slide, "roundRect", 718, 340, 136, 92, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", 1090, 236, 90, 152, COLOR.white, COLOR.line, 1.1);
    addShape(slide, "roundRect", 1110, 254, 50, 20, `${accent}28`, "#00000000", 0);
    addShape(slide, "roundRect", 1110, 286, 50, 42, `${COLOR.gold}30`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy, sw, 74, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 96, sw, 78, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx + 24, sy + 198, sw - 48, 48, accent, "#00000000", 0);
    return;
  }

  if (type === "routing") {
    addShape(slide, "roundRect", 720, 222, 118, 152, COLOR.white, COLOR.line, 1.1);
    addShape(slide, "roundRect", 720, 402, 118, 74, `${accent}16`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy, sw, 74, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 14, sy + 112, sw - 28, 102, COLOR.white, COLOR.line, 1.1);
    addShape(slide, "roundRect", sx + 34, sy + 136, sw - 68, 18, `${accent}26`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 34, sy + 166, sw - 104, 18, `${COLOR.gold}24`, "#00000000", 0);
    addShape(slide, "roundRect", sx + 22, sy + 252, sw - 44, 44, accent, "#00000000", 0);
    return;
  }

  if (type === "memory") {
    addShape(slide, "ellipse", 742, 256, 88, 88, `${accent}18`, accent, 1.5);
    addShape(slide, "ellipse", 742, 382, 88, 88, `${COLOR.gold}20`, COLOR.gold, 1.5);
    addShape(slide, "roundRect", sx, sy, sw, 74, `${accent}18`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 106, sw, 72, COLOR.white, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 192, sw, 72, `${COLOR.blue}14`, "#00000000", 0);
    addShape(slide, "roundRect", sx, sy + 278, sw, 72, COLOR.white, "#00000000", 0);
    addShape(slide, "rect", 830, 292, 66, 3, accent, "#00000000", 0);
    addShape(slide, "rect", 830, 418, 66, 3, COLOR.gold, "#00000000", 0);
    return;
  }
}

function addSourcesNotes(slide, extra = "") {
  slide.speakerNotes.setText(`${extra}\n\nSources:\n- ${SOURCES.join("\n- ")}`);
}

function slideCover(presentation) {
  const slideNo = 1;
  const slide = presentation.slides.add();
  addBackground(slide, slideNo, COLOR.green);
  addShape(slide, "ellipse", 846, 98, 262, 262, `${COLOR.green}18`, "#00000000", 0);
  addShape(slide, "ellipse", 970, 250, 118, 118, `${COLOR.gold}48`, "#00000000", 0);
  addShape(slide, "ellipse", 1110, 152, 72, 72, `${COLOR.coral}64`, "#00000000", 0);
  addText(slide, slideNo, "Investor preview", 74, 108, 180, 20, {
    size: 12,
    face: FONT.mono,
    color: COLOR.greenDark,
    bold: true,
    role: "cover-kicker",
  });
  addText(slide, slideNo, "Ambitions front-end transformation", 74, 146, 560, 78, {
    size: 42,
    face: FONT.title,
    color: COLOR.ink,
    bold: true,
    role: "cover-title",
  });
  addText(
    slide,
    slideNo,
    "A presentation-ready overview of the future roadmap from Batch 39 through Batch 59, built from the current canonical planning truth.",
    74,
    236,
    520,
    80,
    { size: 21, color: COLOR.graphite, role: "cover-subtitle" },
  );
  addShape(slide, "roundRect", 74, 360, 230, 96, COLOR.white, COLOR.line, 1.1);
  addText(slide, slideNo, "21", 96, 380, 70, 38, { size: 32, face: FONT.title, bold: true, color: COLOR.ink, role: "metric" });
  addText(slide, slideNo, "future transformation batches", 176, 386, 104, 34, { size: 14, role: "metric-copy" });
  addShape(slide, "roundRect", 326, 360, 230, 96, COLOR.white, COLOR.line, 1.1);
  addText(slide, slideNo, "5", 348, 380, 54, 38, { size: 32, face: FONT.title, bold: true, color: COLOR.ink, role: "metric" });
  addText(slide, slideNo, "major product layers redesigned", 426, 386, 100, 34, { size: 14, role: "metric-copy" });
  addShape(slide, "roundRect", 740, 420, 370, 132, COLOR.white, COLOR.line, 1.1);
  addText(slide, slideNo, "Calm. Obvious. Premium. Consumer-native.", 768, 448, 312, 34, {
    size: 24,
    face: FONT.title,
    bold: true,
    color: COLOR.ink,
    role: "cover-moment",
  });
  addText(slide, slideNo, "The end state is a high-trust external brain that feels authored across every screen and every device surface.", 768, 494, 296, 40, {
    size: 15,
    color: COLOR.graphite,
    role: "cover-copy",
  });
  addSlideFooter(slide, slideNo, "Covers only queued future work: Batches 39–59");
  addSourcesNotes(slide, "Cover and framing slide for the investor deck.");
}

function slideStatus(presentation) {
  const slideNo = 2;
  const slide = presentation.slides.add();
  addBackground(slide, slideNo, COLOR.green);
  addText(slide, slideNo, "Where the roadmap stands today", 74, 94, 520, 54, {
    size: 34,
    face: FONT.title,
    bold: true,
    role: "title",
  });
  addText(slide, slideNo, "This presentation begins after the current hardening wave. The live queue remains unchanged: Batch 37 is active, Batch 38 is queued, and the front-end transformation begins at Batch 39.", 74, 154, 548, 84, {
    size: 18,
    role: "summary",
  });

  const cards = [
    ["37", "active now", "Current hardening work remains in progress."],
    ["38", "queued next", "Hardening follow-through lands before the transformation begins."],
    ["39-59", "investor focus", "Every future transformation batch is queued and sequenced."],
    ["0", "optional systems", "Everything in the agreed transformation roadmap is intended to ship."],
  ];
  cards.forEach((card, idx) => {
    const x = 74 + (idx % 2) * 268;
    const y = 300 + Math.floor(idx / 2) * 148;
    addShape(slide, "roundRect", x, y, 244, 126, COLOR.white, COLOR.line, 1.1);
    addText(slide, slideNo, card[0], x + 20, y + 20, 100, 34, { size: 30, face: FONT.title, bold: true, color: COLOR.ink, role: "status-metric" });
    addText(slide, slideNo, card[1], x + 20, y + 58, 120, 18, { size: 12, face: FONT.mono, bold: true, color: COLOR.greenDark, role: "status-label" });
    addText(slide, slideNo, card[2], x + 20, y + 84, 196, 28, { size: 13, color: COLOR.graphite, role: "status-copy" });
  });

  addShape(slide, "roundRect", 704, 128, 458, 468, COLOR.white, COLOR.line, 1.1);
  addText(slide, slideNo, "Transformation arcs", 730, 154, 160, 20, { size: 12, face: FONT.mono, bold: true, color: COLOR.greenDark, role: "subhead" });
  const arcs = [
    ["39-42", "Foundation", COLOR.green],
    ["43-50", "Flagship surfaces", COLOR.gold],
    ["51-53", "Trust and reflection", COLOR.coral],
    ["54-56", "Ambient extension", COLOR.blue],
    ["57-58", "Multi-device", COLOR.navy],
    ["59", "Flagship finish", COLOR.greenDark],
  ];
  arcs.forEach((arc, idx) => {
    const y = 198 + idx * 58;
    addShape(slide, "roundRect", 730, y, 88, 28, `${arc[2]}18`, arc[2], 1.1);
    addText(slide, slideNo, arc[0], 746, y + 8, 56, 14, { size: 11, face: FONT.mono, bold: true, color: arc[2], role: "arc-range" });
    addText(slide, slideNo, arc[1], 842, y + 6, 220, 20, { size: 18, face: FONT.title, bold: true, color: COLOR.ink, role: "arc-title" });
  });
  addText(slide, slideNo, "The message for investors is simple: the roadmap is now fully defined, fully batched, and fully mandatory. The remaining work is not discovery drift. It is execution.", 730, 574, 356, 44, {
    size: 16,
    color: COLOR.graphite,
    role: "status-close",
  });
  addSlideFooter(slide, slideNo, "Current operational truth preserved: Batch 37 active, Batch 38 queued");
  addSourcesNotes(slide, "Status slide grounded in the batch registry and future transformation canon.");
}

function slideRoadmap(presentation) {
  const slideNo = 3;
  const slide = presentation.slides.add();
  addBackground(slide, slideNo, COLOR.green);
  addText(slide, slideNo, "The roadmap from Batch 39 to Batch 59", 74, 94, 560, 54, {
    size: 34,
    face: FONT.title,
    bold: true,
    role: "title",
  });
  addText(slide, slideNo, "The transformation is sequenced to protect clarity, avoid shell instability, and move from platform foundations into flagship surfaces, ambient extensions, and multi-device expansion.", 74, 154, 650, 54, {
    size: 18,
    role: "summary",
  });

  const lanes = [
    { title: "Foundation", range: "39-42", accent: COLOR.green, items: ["Canon", "Shell", "Design system", "Command layer"] },
    { title: "Flagship surfaces", range: "43-50", accent: COLOR.gold, items: ["Today", "Goals", "Goal Detail", "Plan"] },
    { title: "Trust and reflection", range: "51-53", accent: COLOR.coral, items: ["Insights", "Profile", "Onboarding"] },
    { title: "Ambient extension", range: "54-56", accent: COLOR.blue, items: ["Widgets", "Shortcuts", "Recall coherence"] },
    { title: "Multi-device + finish", range: "57-59", accent: COLOR.navy, items: ["iPad/Mac", "Watch/TV", "Polish"] },
  ];

  lanes.forEach((lane, idx) => {
    const y = 246 + idx * 82;
    addShape(slide, "roundRect", 74, y, 190, 58, `${lane.accent}16`, lane.accent, 1.2);
    addText(slide, slideNo, lane.range, 92, y + 10, 62, 16, { size: 11, face: FONT.mono, bold: true, color: lane.accent, role: "lane-range" });
    addText(slide, slideNo, lane.title, 92, y + 26, 150, 22, { size: 21, face: FONT.title, bold: true, color: COLOR.ink, role: "lane-title" });
    addShape(slide, "rect", 288, y + 28, 824, 2, `${lane.accent}55`, "#00000000", 0);
    lane.items.forEach((item, itemIdx) => {
      const x = 322 + itemIdx * 196;
      addShape(slide, "ellipse", x, y + 13, 30, 30, lane.accent, "#00000000", 0);
      addText(slide, slideNo, item, x + 42, y + 16, 136, 18, { size: 13, color: COLOR.ink, bold: true, role: "lane-item" });
    });
  });

  addShape(slide, "roundRect", 802, 564, 310, 76, COLOR.white, COLOR.line, 1.1);
  addText(slide, slideNo, "Execution logic", 826, 584, 120, 16, { size: 11, face: FONT.mono, bold: true, color: COLOR.greenDark, role: "logic-head" });
  addText(slide, slideNo, "Build the shell first. Prove the core surfaces. Extend trust and ambient value. Expand outward only after the iPhone truth is stable.", 826, 606, 258, 24, { size: 13, color: COLOR.graphite, role: "logic-copy" });
  addSlideFooter(slide, slideNo, "Ordered exactly as the queued future transformation program will be completed");
  addSourcesNotes(slide, "Overview slide for the future queue from Batch 39 through Batch 59.");
}

function slideBatch(presentation, batch, position) {
  const slideNo = position + 3;
  const slide = presentation.slides.add();
  addBackground(slide, slideNo, batch.accent);
  addSectionHeader(slide, slideNo, batch, batch.accent);
  addOutcomeBlocks(slide, slideNo, batch, batch.accent);
  drawMockup(slide, slideNo, batch);
  addSlideFooter(slide, slideNo, `Queued future batch ${batch.batch} of 59`);
  addSourcesNotes(slide, `Batch ${batch.batch} investor-summary slide.`);
}

async function createDeck() {
  await ensureDirs();
  const presentation = Presentation.create({ slideSize: { width: W, height: H } });
  slideCover(presentation);
  slideStatus(presentation);
  slideRoadmap(presentation);
  BATCHES.forEach((batch, idx) => slideBatch(presentation, batch, idx + 1));
  return presentation;
}

async function saveBlobToFile(blob, filePath) {
  const bytes = new Uint8Array(await blob.arrayBuffer());
  await fs.writeFile(filePath, bytes);
}

async function exportDeck(presentation) {
  const pptxBlob = await PresentationFile.exportPptx(presentation);
  const pptxPath = path.join(OUT_DIR, "output.pptx");
  await pptxBlob.save(pptxPath);

  for (let idx = 0; idx < presentation.slides.items.length; idx += 1) {
    const preview = await presentation.export({ slide: presentation.slides.items[idx], format: "png", scale: 1 });
    await saveBlobToFile(preview, path.join(PREVIEW_DIR, `slide-${String(idx + 1).padStart(2, "0")}.png`));
  }

  const inspectLines = [{ kind: "deck", slideCount: presentation.slides.count }, ...inspect]
    .map((item) => JSON.stringify(item))
    .join("\n");
  await fs.writeFile(INSPECT_PATH, `${inspectLines}\n`, "utf8");
  return pptxPath;
}

const presentation = await createDeck();
const pptxPath = await exportDeck(presentation);
console.log(pptxPath);
