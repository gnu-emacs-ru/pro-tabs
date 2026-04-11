# HOLO

Stage: RealityCheck

Purpose: Provide a reusable Emacs tab UI for `tab-bar` and `tab-line` with predictable enable/disable behavior, theme awareness, cached rendering, and headless verification.

Invariants:
- Core rendering stays pure where practical.
- Side effects stay inside `pro-tabs-mode` and its restore path.
- `pro-tabs-mode` can be toggled repeatedly without leaving Emacs in a broken key/input state.
- Tab-line/tab-bar defaults are restored on disable.
- Theme changes refresh faces, cached wave specs, and displayed tab state.
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
- Wave separators are precomputed and cached by backend, state, direction, and height.
- Icons and formatted strings use caches that are invalidated by generation bumps.
- `pro-tabs-tabs-function-fast` computes tab-line buffers with per-window caching.

Runtime behavior:
- `pro-tabs-mode` installs and removes tab-bar/tab-line defaults.
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
