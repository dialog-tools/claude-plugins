---
name: dialog-design-v2
description: Design system v2 for the Dialog app repo — light-first, Fraunces + Plus Jakarta Sans, indigo/peach. Use when writing or reviewing any UI inside a data-ds="v2" scope, touching files under frontend/src/design-system/, building a v2 prototype (designSystem 'v2' in frontend/src/prototypes/), or migrating v1 surfaces, tokens, or Tailwind classes to v2.
---

# Dialog design system v2

This file is an index, not a style guide. It routes you to the right source
file and states the rules that are never optional. Everything else lives in
the design system itself (`frontend/src/design-system/` in the app repo) and
in the [references](#references) below.

## Your training data is stale here

v2 reuses v1's component names — `Button`, `Badge`, `Sidebar` — with
**different props, different tokens, and different rules**. The `data-ds="v2"`
wrapper decides which system's rules apply. Never carry a prop, class name, or
color you remember from v1 (or from any other component library) into v2 code.
When in doubt, the `.d.ts` file is the contract; this skill tells you when to
read which one.

## Hard rules (procedures, not preferences)

1. **Read the component's `.d.ts` before using any prop.** Path:
   `frontend/src/design-system/components/<group>/<Name>.d.ts`. If a prop is
   not in the `.d.ts`, it does not exist — do not infer it from naming
   conventions or other libraries. Stop and ask.
2. **Reuse before creating.** The system has exactly 35 components (index
   below). There is no Tabs, Accordion, or Popover — the source defines none.
   If the index has no fit, say so and ask; do not invent a component.
3. **Never a raw hex color.** Use a `--ds2-*` semantic token or a `v2-*`
   Tailwind utility ([tokens](references/tokens.md)). The app repo lints hex
   literals in `frontend/src` — a hex you write is a warning you created.
   Never reference `--ds2-primitive-*` directly either; use the semantic
   alias.
4. **Everything v2 renders inside `data-ds="v2"`.** All tokens and component
   CSS are scoped under that attribute — outside it they resolve to nothing.
   Prototypes get the wrapper from `PrototypeHost` when meta says
   `designSystem: 'v2'`; never add a nested duplicate wrapper.
5. **Never read v2 colors via `getComputedStyle` for charts or canvas.**
   Computed values come back as `oklab(...)`, which `d3-color` (and therefore
   recharts) parses as `null`. Read the raw `--ds2-*` custom property value
   instead.
6. **Indigo is structural, peach is the CTA accent — never mix the roles.**
   No peach navigation, no indigo hero CTA. On peach fills, text is ink
   (`--ds2-color-text-primary`), never white.
7. **Convert design px to rem at ÷16.** The app root runs `font-size: 80%`,
   so 1rem renders at 12.8px and ÷16 lands v2 at app density. Do not
   "compensate" by scaling values up.
8. **Dark mode is out of scope.** `tokens/dark.css` exists but is deliberately
   not imported. Do not wire `data-theme="dark"` or add dark variants; dark
   ships after the light-first migration completes.
9. **Migrating v1 classes/tokens?** Follow [migration](references/migration.md)
   exactly. Rows marked *no equivalent — stop and ask* mean exactly that:
   neither you nor a codemod guesses.
10. **Production code never imports from `frontend/src/design-system/`**
    (ESLint-enforced, prototype phase). v2 work happens in
    `frontend/src/prototypes/` until the migration gate passes.

## Component index

Import from the barrel: `frontend/src/design-system/components/index.ts`.
Per-component files sit at
`frontend/src/design-system/components/<group>/<Name>.jsx` with a `.d.ts`
props contract and a `.prompt.md` usage note beside each. **Read the
`.prompt.md` + `.d.ts` the first time you use a component in a session; skip
if you already read them this session.**

### core/

| Component | Use for | Only read when |
|---|---|---|
| `Button` | Pill action control; indigo default, peach `cta` variant for the one most-wanted action | adding any action control |
| `IconButton` | Compact square icon-only button (settings, search, dismiss) | an action has no label |
| `Badge` | Small pill labelling agent state or counts | showing state/counts inline |
| `StatusDot` | 7px run-state dot in lists, sidebars, badges | showing live agent state |
| `Tag` | Squarer, dismissible chip for keywords/sources/filters | chips that can be removed |
| `Avatar` | Round avatar for sidebar user block and team lists | showing a person |
| `Divider` | Hairline separator, optional caps label ("OR") | separating stacked content |
| `Icon` | Lucide glyph inheriting parent text color | any icon — never hand-rolled SVG |

### forms/

| Component | Use for | Only read when |
|---|---|---|
| `Input` | Labelled text field — the default form control | collecting a single value |
| `Textarea` | Plain-English description field | multi-line user intent |
| `Select` | Dropdown for a fixed option set (schedules, channels) | choosing one of N |
| `Toggle` | On/off switch for immediate-effect settings | boolean settings |
| `TagInput` | Multi-value entry (keywords, competitors, sources) | collecting a list |
| `SearchBar` | Pill-shaped search for lists and knowledge base | filtering a collection |

### cards/

| Component | Use for | Only read when |
|---|---|---|
| `AgentCard` | A running agent on the dashboard — name, state, last run | listing agents |
| `TemplateCard` | A pre-built agent adoptable in one click | template galleries |
| `ResultCard` | An insight delivery — finding, detail, sources | rendering agent output |
| `StatCard` | Headline number for the dashboard summary row | KPI rows |
| `ToolTile` | Pick-your-sources tile — logo, name, connection state | source/integration pickers |

### navigation/

| Component | Use for | Only read when |
|---|---|---|
| `Sidebar` (+ `SidebarSection`, `SidebarDivider`) | The persistent left rail | building an app shell |
| `NavItem` | One sidebar row | sidebar entries |
| `AgentNavItem` | Sidebar agent row with live state | agents in the sidebar |
| `TopBar` | The 56px sticky page header | page headers |
| `Breadcrumbs` | Locates a detail view in the app | detail-view headers |

### feedback/

| Component | Use for | Only read when |
|---|---|---|
| `Toast` (+ `ToastRegion`) | Non-blocking confirmation (created, failed, new results) | async outcomes |
| `Modal` | Focused task or confirmation without leaving the page | interrupting flows |
| `EmptyState` | Pre-content view, always with a way forward | zero-data states |
| `Skeleton` | Loading placeholder matched to real content dimensions | loading states |
| `ProgressBar` | Thin linear progress under a wizard header | determinate progress |
| `StepIndicator` | The onboarding wizard's progress spine | multi-step flows |
| `Tooltip` | Names an icon-only control on hover | icon-only affordances |
| `CoachMark` | Teaches one thing on first run, then gone for good | first-run education |

Deprecations: none yet — v2 is pre-freeze. When a component is deprecated it
will be marked in its row here.

## Larger source material

- `frontend/src/design-system/readme.md` — voice, copy patterns, visual
  foundations, iconography. Read before writing any user-facing copy or
  marketing surface.
- `frontend/src/design-system/ui_kits/app/` — full app-shell screens
  (dashboard, agent detail, wizard, knowledge base). Read when composing a
  whole screen; copy composition patterns from here rather than inventing
  layout.
- `frontend/src/design-system/css/components.css` — the visual truth every
  React component wraps. Read only when a component renders wrong and you need
  to know why; never edit it to fix a call site.
- Tailwind `v2-*` color utilities: defined in the app repo's
  `tailwind.config.js` (color-mix wrappers so `/50` opacity works). Full list
  in [tokens](references/tokens.md).

## References

| File | Only read when |
|---|---|
| [references/tokens.md](references/tokens.md) | picking any color, type, spacing, radius, shadow, motion, or z value |
| [references/decision-tree.md](references/decision-tree.md) | unsure which component fits a job, or porting a v1 pattern with no obvious v2 twin |
| [references/migration.md](references/migration.md) | converting v1 Tailwind color classes or tokens to v2 (generated from `token-map.ts` — do not hand-edit) |
