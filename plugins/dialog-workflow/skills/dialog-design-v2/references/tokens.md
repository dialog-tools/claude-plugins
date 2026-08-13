# v2 tokens — values inline

Source of truth: `frontend/src/design-system/tokens/*.css` (app repo). Values
are inlined here so you never guess; if this file and the CSS disagree, the
CSS wins — flag the drift.

All tokens are scoped under `[data-ds="v2"]` and prefixed `--ds2-`. Use
**semantic** tokens in code; primitives are listed only so you can recognize
values on sight. Never reference `--ds2-primitive-*` directly.

## Color — semantic tokens (use these)

| Token | Resolves to | Role |
|---|---|---|
| `--ds2-color-brand` | `#5b6bbf` indigo | Structural brand: nav, links, primary buttons, focus, active states |
| `--ds2-color-brand-hover` | `#3d4e9e` | Hover for brand fills |
| `--ds2-color-brand-pale` | `#eef0fa` | Ghost-button fill, brand tint backgrounds |
| `--ds2-color-brand-deep` | `#3d4e9e` | Deep structural accents |
| `--ds2-color-interactive` | `#e8856a` peach | THE CTA accent — one most-wanted action per view; "running" state |
| `--ds2-color-interactive-hover` | `#c45e42` | Hover for peach fills |
| `--ds2-color-interactive-pale` | `#fdf0eb` | Peach tint backgrounds |
| `--ds2-color-bg-base` | `#fffaf1` warm off-white | The page. Never pure white |
| `--ds2-color-bg-surface` | `#ffffff` | Cards — they sit *above* the page |
| `--ds2-color-bg-recessed` | `#f2f0f9` cool lilac-grey | Sidebars, input fills — *below* the page |
| `--ds2-color-bg-tinted` | `#e6e3f5` | Deeper recessed tint |
| `--ds2-color-bg-overlay` | `rgba(28,26,46,0.4)` | Modal scrim |
| `--ds2-color-border` | `#e0dcf2` | 1px card borders |
| `--ds2-color-border-mid` | `#cac5e0` | 1.5px interactive borders (inputs, buttons, tiles) |
| `--ds2-color-border-focus` | `#5b6bbf` | Focus border |
| `--ds2-color-text-primary` | `#1c1a2e` ink | Headings, body. Also the text on peach fills (never white) |
| `--ds2-color-text-secondary` | `#3d3a55` | Secondary copy |
| `--ds2-color-text-muted` | `#6e6b80` | Meta, captions |
| `--ds2-color-text-faint` | `#ada9c0` | Placeholders, disabled |
| `--ds2-color-text-on-brand` | `#ffffff` | Text on indigo fills only |
| `--ds2-color-text-on-dark` | `#ffffff` | Text on dark photo scrims |
| `--ds2-color-text-brand` | `#5b6bbf` | Links, brand-colored text |
| `--ds2-color-text-heading` | `#1c1a2e` | Explicit heading color |
| `--ds2-color-success` / `-bg` | `#2d7d56` / `#ebf5f0` | Success text/fill on tint |
| `--ds2-color-warning` / `-bg` | `#a0650a` / `#fef8ec` | Warning |
| `--ds2-color-error` / `-bg` | `#c43030` / `#fdf0f0` | Error |
| `--ds2-color-info` / `-bg` | `#3d4e9e` / `#eef0fa` | Info |
| `--ds2-color-sidebar-bg` | `#f2f0f9` | Sidebar chrome |
| `--ds2-color-sidebar-text` / `-active` | `#514e6b` / `#3d4e9e` | Sidebar rows |
| `--ds2-color-sidebar-item-active` / `-hover` | `#ffffff` / `rgba(91,107,191,0.06)` | Row fills |
| `--ds2-color-sidebar-label` | `#6e6b84` | Section labels |
| `--ds2-color-status-active` | indigo `#5b6bbf` | Agent: active |
| `--ds2-color-status-running` | peach `#e8856a` | Agent: running |
| `--ds2-color-status-paused` | `#ada9c0` | Agent: paused |
| `--ds2-color-status-error` | `#c43030` | Agent: error |

## Tailwind `v2-*` utilities (app repo `tailwind.config.js`)

Color-mix wrappers over the semantic tokens, so opacity modifiers
(`bg-v2-brand/50`) work. Available for `bg-`, `text-`, `border-`, `ring-`,
`divide-` etc.:

`v2-page` `v2-surface` `v2-recessed` `v2-ink` `v2-ink-secondary` `v2-muted`
`v2-line` `v2-brand` `v2-brand-pale` `v2-cta` `v2-success` `v2-warning`
`v2-error`

Anything not in that list (spacing, radius, shadows) is used via the DS
component classes or inline `var(--ds2-…)` — there is no v2 Tailwind slice
for non-color tokens.

## Typography

Fonts: `--ds2-font-display` Fraunces (serif — display, H1, H2, card titles,
stat values, modal titles; **always weight 400, never bold**; italic + accent
color is the one flourish). `--ds2-font-body` Plus Jakarta Sans (everything
else; 600 for H3/H4 and buttons). `--ds2-font-mono` SF Mono / Fira Code.
Never request Fraunces' SOFT/WONK axes.

Sizes (rem at ÷16 — the app root is `font-size: 80%`, so 1rem renders 12.8px):

| Token | Value | Use |
|---|---|---|
| `--ds2-text-xs` | 0.625rem | Labels, eyebrows, status chips |
| `--ds2-text-sm` | 0.75rem | Meta, timestamps, captions |
| `--ds2-text-base` | 0.875rem | Body, nav items, form inputs |
| `--ds2-text-md` | 1rem | Card descriptions, secondary body |
| `--ds2-text-lg` | 1.25rem | H3 |
| `--ds2-text-xl` | 1.5rem | H2 |
| `--ds2-text-2xl` | 2rem | H1 — Fraunces |
| `--ds2-text-3xl` | 2.5rem | Display — hero headlines |
| `--ds2-text-4xl` | 3.25rem | Display XL — marketing only |

Weights: light 300 · regular 400 · medium 500 · semibold 600 · bold 700.
Leading: tight 1.1 · snug 1.25 · normal 1.5 · relaxed 1.65 (body) · loose 1.8
(long-form results). Tracking: tight −0.02em (all Fraunces + wordmark) ·
wide 0.04em · wider 0.08em · widest 0.14em (the 10px caps eyebrow).

## Spacing — strict 8pt grid (4px only sub-step)

`--ds2-space-{1,2,3,4,5,6,8,10,12,16,20,24,32}` =
0.25 / 0.5 / 0.75 / 1 / 1.25 / 1.5 / 2 / 2.5 / 3 / 4 / 5 / 6 / 8 rem.
Cards pad 20–24px; app sections 32px; marketing sections 96px vertical.

## Radius

| Token | Value | Use |
|---|---|---|
| `--ds2-radius-xs` | 4px | Inline badges |
| `--ds2-radius-sm` | 8px | Nav items, chips, inner cards |
| `--ds2-radius-md` | 12px | Inputs, selects, dropdowns, small cards |
| `--ds2-radius-lg` | 16px | Cards, panels |
| `--ds2-radius-xl` | 20px | Modals, large panels |
| `--ds2-radius-2xl` | 28px | Hero / bento / photo clips |
| `--ds2-radius-pill` | 100px | Buttons, badges, tags, search — always fully pill |

Nothing is square except rules and progress tracks.

## Shadows — ink-tinted `rgba(28,26,46,…)`, never neutral black

| Token | Value |
|---|---|
| `--ds2-shadow-subtle` | `0 1px 3px rgba(28,26,46,.06), 0 1px 2px rgba(28,26,46,.04)` |
| `--ds2-shadow-resting` | `0 2px 8px rgba(28,26,46,.08), 0 1px 3px rgba(28,26,46,.05)` |
| `--ds2-shadow-elevated` | `0 8px 24px rgba(28,26,46,.10), 0 2px 8px rgba(28,26,46,.06)` |
| `--ds2-shadow-modal` | `0 24px 64px rgba(28,26,46,.16), 0 4px 16px rgba(28,26,46,.08)` |
| `--ds2-shadow-focus` | `0 0 0 3px rgba(91,107,191,.25)` — every interactive element |

No inner shadows. Card borders are deliberately low-contrast; the shadow
carries the shape — don't remove it to "simplify".

## Motion

Durations: instant 80ms · fast 150ms · normal 220ms · slow 350ms · slower
500ms. Eases: `--ds2-ease-default` `cubic-bezier(.16,1,.3,1)` (snappy
ease-out, the default) · `--ds2-ease-spring` `cubic-bezier(.34,1.56,.64,1)`
(modals, toasts, toggle thumb only). Composites:
`--ds2-transition-{colors,transform,shadow,all}`. Press = 1px translateY,
never scale. All motion collapses under `prefers-reduced-motion`. No bounces
in product UI.

## Layout & stacking

Sidebar 240px (60px collapsed) · top bar 56px sticky · content max 1200px ·
content padding 32px (`--ds2-layout-*`). Z: below −1 · base 0 · raised 10 ·
dropdown 100 · sticky 200 · overlay 300 · modal 400 · toast 500 · tooltip 600
(`--ds2-z-*`).
