# Which component for which job

Route from the job to the component, then read its `.prompt.md` + `.d.ts`
(`frontend/src/design-system/components/<group>/<Name>.*`) before writing
props.

## I need to…

**…let the user act**
- One clear action → `Button` variant `primary` (indigo).
- THE most-wanted action on the view (max one per view) → `Button` variant
  `cta` (peach, ink text).
- Secondary/tertiary action → `Button` `secondary` (outline) or `ghost`
  (pale indigo fill).
- Dangerous action → `Button` `destructive`.
- Action with no room for a label → `IconButton` + `Tooltip` (icon-only
  controls are always tooltipped).

**…show state or metadata**
- Agent run state, counts → `Badge`. Just the state, no text → `StatusDot`.
- Removable keyword/source/filter chips → `Tag` (squarer than Badge,
  dismissible). Not removable → `Badge`.
- A headline metric → `StatCard`. An insight with sources → `ResultCard`.

**…collect input**
- One line of text → `Input`. Multi-line intent ("what should the agent
  watch?") → `Textarea`.
- One of a fixed set → `Select`. Instant-effect boolean → `Toggle`.
- A list of values (keywords, competitors) → `TagInput`.
- Filtering a collection → `SearchBar` (pill), not a bare `Input`.

**…give feedback**
- Something finished in the background → `Toast` (2–3 word past-tense title +
  one consequence sentence). Needs a decision before continuing → `Modal`.
- Nothing here yet → `EmptyState` (state the fact plainly + always a next
  step). Content loading → `Skeleton` sized like the real content.
- Progress through a wizard → `StepIndicator` (spine) and/or `ProgressBar`
  (thin bar under the header).
- Teach a first-run feature once → `CoachMark`. Name an icon → `Tooltip`.

**…build page chrome**
- App shell → `Sidebar` + `SidebarSection`/`SidebarDivider` + `NavItem`
  (`AgentNavItem` for agent rows) + `TopBar`. Detail views add `Breadcrumbs`.
- Composing a full screen → copy composition from
  `frontend/src/design-system/ui_kits/app/` rather than inventing layout.

## Does not exist — stop and ask

No Tabs, Accordion, Popover, dropdown menu (beyond `Select`), table, date
picker, pagination, or drawer. The source system defines none. Do not build
one ad hoc or import one from another library; flag the gap.

## v1 → v2 choice differences

Porting a v1 surface is not a color swap — some v1 *choices* map to different
v2 choices:

| v1 habit (dark-first production) | v2 rule |
|---|---|
| Accent glows, gradient washes (`onboarding-glow`, orb-pulse) | **No decorative gradients anywhere.** Protection is by scrim or capsule; the only glow is the marketing hero ring pulse |
| White text on accent fills | On peach, text is **ink** `#1c1a2e`, never white. White text only on indigo |
| Dark cards separated by borders | White cards on warm off-white, shape carried by ink-tinted shadow; borders are quiet (1px) |
| Hover = scale up | Hover = darken + shadow lift; press = 1px translateY. **Never scale** |
| `lucide-react` icon components | DS `Icon` (Lucide via `window.lucide` UMD contract). In prototypes, adapt the ESM `lucide` package at module scope — see the v2 tour prototype for the adapter |
| Emoji in UI copy | **Never.** Only ✓ ⚠ → ↑ ↓ as typographic marks in their three sanctioned spots |
| Buttons/inputs at 6–8px radius | Buttons, badges, tags, search are **fully pill**; inputs/selects 12px |
| Bold display headings | Fraunces display is **always weight 400**; emphasis via size and the italic-accent `<em>` flourish |
| Title Case labels | Sentence case everywhere; the caps eyebrow style is the only uppercase |
| Pure-white page background | Page is warm off-white `#fffaf1`; pure white is reserved for cards |

For token-by-token class conversions, use [migration.md](migration.md) — and
respect its *no equivalent — stop and ask* rows.
