# Marketing copy — Adaptive Fitness Tracker

> Ready-to-paste, English-first. Live URL: **https://jeiriz.gumroad.com/l/cajakq**
> Once the Etsy listing is live, swap in that URL where it fits the audience better.
> Image assets in `mockups/` (`00_cover_wide.png`, `01_cover.png`, `03_dashboard.png`).

---

## Pinterest (main channel for templates/fitness)

Vertical pins (1000×1500) convert best — `mockups/03_dashboard.png` is horizontal,
so crop a tall version showing the Dashboard + coach text. 3 pins to A/B:

**Pin 1 — the "scale is lying" hook**
- Title: `Your scale is lying to you (here's the fix)`
- Description: `Daily weight swings 1–2% from water and stress — that's why most people quit. This spreadsheet reads your 7-day trend and tells you exactly when to cut, hold, or add calories back. Excel + Google Sheets. #fitnesstracker #macrocalculator #weightloss #excel`
- Link: https://jeiriz.gumroad.com/l/cajakq

**Pin 2 — the "coaches you back" angle**
- Title: `A spreadsheet that coaches you back`
- Description: `TDEE + macros, 7-day trend weight, RIR workout log with auto 1RM and PR flags — all wired together so it tells you what to do next. Cut, maintain or bulk. #gymtok #macros #tdee #fitnessspreadsheet #progressiveoverload`
- Link: https://jeiriz.gumroad.com/l/cajakq

**Pin 3 — the "built by a lifter who codes" trust angle**
- Title: `Most fitness templates just store numbers. This one thinks.`
- Description: `Built by a lifter who codes. Log your morning weight; it filters the noise, compares to your goal, and protects muscle on a cut. Metric & Imperial, free updates. #weighttrend #cutting #bulking #gymtracker`
- Link: https://jeiriz.gumroad.com/l/cajakq

---

## Reddit (value-first — most fitness subs ban links)

Rule of thumb: contribute genuinely, link only where allowed, never spam.
Safest fits:
- **r/excel / r/spreadsheets / r/GoogleSheets** — share as a "built this, here's how
  the trend logic works" post. These subs tolerate templates if the post teaches.
- **r/loseit, r/fitness, r/gainit** — NO direct links. Comment helpfully; put the
  product in your profile/flair. Day-one link-drops get removed and can ban.

**r/excel post (teaching framing, link OK in body or comment):**
```
Title: Built a fitness tracker that reacts to your 7-day weight trend instead of daily noise — sharing the formula approach

Body: The core problem with weight spreadsheets is daily weigh-ins swing 1–2%
from water/sodium, so a raw number tells you nothing. I used a 7-day moving
average (AVERAGE over a trailing OFFSET window) plus weekly rate as % of
bodyweight, then an IFS() ladder that maps that rate to a plain-English
suggestion (hold / drop ~150 kcal / add back). The workout tab converts each
set to an estimated 1RM (Epley) and flags PRs with MAXIFS. Happy to explain
any of the formulas. [link in profile / comment if allowed]
```

---

## X / Twitter / Threads

```
Most fitness templates just store numbers.

This one reads your 7-day trend, ignores the daily water-weight noise, and
tells you in plain words: hold, cut ~150 kcal, or add back.

Excel + Google Sheets. Built by a lifter who codes.
→ jeiriz.gumroad.com/l/cajakq
```

Hashtags: #fitness #macros #tdee #excel #weightloss #gymtok

---

## Notes
- Cross-sell: link the Guitar SFX pack only if the audience overlaps (rare) — skip.
- A/B the Pinterest title starting with the keyword: "TDEE Macro Calculator …".
- Track each post in `metricas/metricas.csv` (one row per product×platform×week).
