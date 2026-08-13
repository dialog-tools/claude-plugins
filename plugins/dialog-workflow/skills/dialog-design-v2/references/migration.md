<!-- GENERATED from frontend/src/design-system/migration/token-map.ts (app repo).
     Do not hand-edit. Regenerate: npm run design:migration-doc (app repo).
     Source hash: sha256:ad23890ac35c -->

# v1 → v2 migration map

Generated from the typed mapping module — the same source the v2-skin preview
and the migration lint use, so this table cannot drift from them (only from
an unregenerated commit; the hash above identifies the source version).

How to read it: find the v1 Tailwind color name, then pick the column for how
the class uses it — `bg-` / `text-` / `border-`(+ring/divide). Cells name
the `v2-*` Tailwind utility when one exists, otherwise the raw CSS variable.
**`provisional` rows have not been designer-reviewed — apply them, but flag
the row in your PR description.**

## Mappings

| v1 name | as bg | as text | as border | status | note |
|---|---|---|---|---|---|
| `white` | `v2-surface` | `v2-ink` | `v2-line` | provisional | v1 white = text/shine on dark → ink text / surface bg in v2. Alpha overlays (white/5 etc.) become near-invisible on light — correct. |
| `black` | `var(--ds2-color-bg-overlay)` | `v2-ink` | `var(--ds2-color-border-mid)` | provisional | bg-black in v1 is almost always a scrim → v2 overlay token. |
| `gray-800` | `v2-recessed` | `v2-ink-secondary` | — | provisional | Stock Tailwind gray, used for code-block styling — shouldn't exist in v1 either. |
| `gray-900` | `v2-recessed` | `v2-ink` | — | provisional | Stock Tailwind gray — same cleanup candidate as gray-800. |
| `onboarding-bg` | `v2-page` | — | — | provisional |  |
| `onboarding-deep` | `v2-recessed` | — | — | provisional |  |
| `onboarding-card` | `v2-surface` | — | — | provisional |  |
| `onboarding-line` | `v2-line` | — | `var(--ds2-color-border-mid)` | provisional |  |
| `onboarding-glow` | `v2-brand` | `v2-brand` | `v2-brand` | provisional |  |
| `onboarding-accent` | `v2-brand` | `v2-brand` | `v2-brand` | provisional |  |
| `surface-page` | `v2-page` | — | — | provisional |  |
| `surface-card` | `v2-surface` | — | — | provisional |  |
| `surface-inset` | `v2-recessed` | — | — | provisional |  |
| `surface-chip` | `var(--ds2-color-bg-tinted)` | — | — | provisional |  |
| `surface-line` | `v2-line` | — | `v2-line` | provisional |  |
| `surface-line-soft` | `v2-line` | — | `v2-line` | provisional |  |
| `surface-line-strong` | — | — | `var(--ds2-color-border-mid)` | provisional |  |
| `brand-primary-primary` | `v2-brand` | `v2-brand` | `var(--ds2-color-border-focus)` | provisional |  |
| `brand-primary-secondary` | `v2-surface` | `var(--ds2-color-text-on-brand)` | — | provisional | v1 uses white both as on-brand text and as a surface — context decides. |
| `brand-primary-tertiary` | `var(--ds2-color-brand-deep)` | `var(--ds2-color-brand-deep)` | `var(--ds2-color-brand-deep)` | provisional |  |
| `brand-primary-surface` | `v2-brand-pale` | — | `var(--ds2-color-border-mid)` | provisional |  |
| `brand-primary-highlight` | `v2-brand-pale` | — | — | provisional |  |
| `brand-primary-contrast` | `v2-page` | `v2-ink` | — | provisional | v1 pure black — inverted role in a light system. |
| `brand-secondary-primary` | `var(--ds2-color-bg-tinted)` | — | `var(--ds2-color-border-mid)` | provisional |  |
| `brand-secondary-secondary` | `var(--ds2-color-bg-tinted)` | `v2-muted` | `var(--ds2-color-border-mid)` | provisional |  |
| `brand-secondary-tertiary` | `v2-surface` | — | — | provisional |  |
| `brand-secondary-highlight` | `v2-page` | — | — | provisional |  |
| `brand-secondary-contrast` | — | `v2-ink` | — | provisional |  |
| `grey-primary` | `v2-surface` | `v2-ink` | — | provisional |  |
| `grey-secondary` | — | `v2-ink-secondary` | — | provisional |  |
| `grey-muted` | — | `v2-muted` | — | provisional |  |
| `grey-tertiary` | — | `var(--ds2-color-text-faint)` | — | provisional |  |
| `grey-highlight` | `var(--ds2-color-bg-tinted)` | `v2-ink-secondary` | — | provisional |  |
| `grey-contrast` | `v2-page` | `v2-ink` | — | provisional |  |
| `success-primary` | `v2-success` | `v2-success` | `v2-success` | provisional |  |
| `success-secondary` | `var(--ds2-color-success-bg)` | `v2-success` | — | provisional |  |
| `success-tertiary` | `var(--ds2-color-success-bg)` | `v2-success` | — | provisional |  |
| `success-highlight` | `var(--ds2-color-success-bg)` | — | — | provisional |  |
| `warning-primary` | `v2-warning` | `v2-warning` | `v2-warning` | provisional |  |
| `warning-secondary` | `var(--ds2-color-warning-bg)` | `v2-warning` | — | provisional |  |
| `warning-tertiary` | — | `v2-warning` | — | provisional |  |
| `warning-highlight` | `var(--ds2-color-warning-bg)` | — | — | provisional |  |
| `error-primary` | `v2-error` | `v2-error` | `v2-error` | provisional |  |
| `error-secondary` | `var(--ds2-color-error-bg)` | `v2-error` | — | provisional |  |
| `error-tertiary` | — | `v2-error` | — | provisional |  |
| `error-highlight` | `var(--ds2-color-error-bg)` | — | — | provisional |  |

A "—" cell means the map does not define that usage context. Do not
improvise: stop and ask, then add the row to `token-map.ts` (never to this
file).

## No equivalent — stop and ask

- `brand-secondary-contrast-gradients` — v1 glow/gradient treatments (orb-pulse, fresh-flash) have no v2 counterpart yet — stop and ask design.

Neither an agent nor a codemod guesses these. Raise them with design.
