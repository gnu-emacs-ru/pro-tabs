# HOLO

Stage: RealityCheck

Purpose: Provide a reusable Emacs tab UI for `tab-bar` and `tab-line` with predictable enable/disable behavior, theme awareness, cached rendering, and headless verification.

Invariants:
- Core rendering stays pure where practical.
- Side effects stay inside `pro-tabs-mode` and its restore path.
- `pro-tabs-mode` can be toggled repeatedly without leaving Emacs in a broken key/input state.
- Tab-line/tab-bar defaults are restored on disable.
- Theme changes refresh faces, cached wave specs, and displayed tab state.
- Theme changes refresh faces so the active tab uses the theme's main background with a bright foreground, while inactive tabs use a darker background.
- The current tab-bar contrast treatment is stabilized and should not be adjusted without an explicit intent change.
- Headless verification covers enable/disable plus a rendering path.

Customization:
- Icons can be enabled or disabled with `pro-tabs-enable-icons`.
- Wavy separators can be enabled or disabled with `pro-tabs-enable-waves`.
- Tab name truncation uses `pro-tabs-max-name-length`.
- Tab-bar/tab-line wave sizing is controlled by `pro-tabs-tab-bar-height` and `pro-tabs-tab-line-height`.
- Tab-line can disable waves and icons past `pro-tabs-tab-line-wave-threshold` and `pro-tabs-tab-line-icons-threshold`.
- Debug logging is opt-in via `pro-tabs-debug-logging`.
- Default quick-select keybindings are opt-in via `pro-tabs-setup-keybindings`.

Rendering model:
- `pro-tabs--format` is the shared formatter with backend-specific wrappers.
- `pro-tabs--format-internal` owns the tab text assembly.
- `pro-tabs--icon-functions` is an ordered provider hook with a fallback bullet provider.
- `tab-bar` and `tab-line` share the same active/inactive face model.
- The active face uses the theme's main background and a bright foreground chosen from theme faces or a white fallback.
- The inactive face uses a background that is darker than the theme's main background.
- Icon provider logic is split into small helpers for face selection, mode dispatch, and fallback handling, and returns a bullet fallback inline.
- Debug logging can explain cache hits, provider misses, and fallback selection for icons.
- Format cache hit/miss logging helps diagnose stale tab strings.
- Buffer icon cache keys include active-state and major-mode so active/inactive tabs can render differently and mode changes invalidate correctly.
- Buffer and format caches are flushed on buffer-list, window-selection, and window-configuration changes.
- Wave separators are precomputed and cached by backend, state, direction, and height.
- Icons and formatted strings use caches that are invalidated by generation bumps and mode toggles.
- `pro-tabs-tabs-function-fast` computes tab-line buffers with per-window caching.

Runtime behavior:
- `pro-tabs-mode` installs and removes tab-bar/tab-line defaults.
- `pro-tabs-mode` clears rendering caches when it is enabled or disabled.
- `pro-tabs-mode` restores the original frame `tab-bar-lines` parameter on disable.
- `pro-tabs-mode` suspends `global-tab-line-mode` while active and restores it on disable when it was previously on.
- `pro-tabs-mode` does not force `tab-line-mode` on in every buffer; it respects buffers the user already enabled.
- `pro-tabs-mode` only suppresses empty tab-line rows in buffers where tab-line is already enabled.
- When `pro-tabs-mode` hides tab-line in a buffer, it restores the buffer's previous `tab-line-format` on disable.
- Theme tracking refreshes faces and reapplies built-in face inheritance.
- `pro-tabs--enable-tab-bar-on-frame` keeps new frames showing tab-bar.
- `pro-tabs-refresh` recomputes face state manually.
- `pro-tabs-flush-caches` clears rendering caches and refreshes UI.
- `pro-tabs-repair-tab-line` resets misconfigured tab-line state.
- `pro-tabs-diagnose` reports current runtime state.

Decisions:
- [Draft] Use a shared formatter for tab-bar and tab-line. Exit: if it causes instability, split the render paths.
- [Draft] Keep icon providers optional. Exit: if providers break rendering, fall back to plain names only.
- [Draft] Keep tab-line caching event-driven rather than redisplay-driven. Exit: if generation-based invalidation proves insufficient, simplify to uncached rendering.
