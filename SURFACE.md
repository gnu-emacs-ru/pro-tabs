# SURFACE

- Name: Mode Toggle
  Stability: [FROZEN]
  Spec: `pro-tabs-mode` enables/disables the package without leaving tab-bar/tab-line unusable.
  Proof: `pro-tabs-test.el` enable/disable test.

- Name: Tab-Bar Rendering
  Stability: [FLUID]
  Spec: `pro-tabs-format-tab-bar` returns formatted tab strings for `tab-bar`.
  Proof: manual/e2e coverage.

- Name: Tab Face Theme
  Stability: [FLUID]
  Spec: `tab-bar` and `tab-line` use the same active/inactive face model. The current tab uses the theme's main background with a bright foreground, inactive tabs use a background that is darker but still readable, and the `tab-bar` track background is darker than the inactive tabs for contrast. If the theme leaves `default` too close to unspecified, pro-tabs falls back to a usable contrasting background. Enabling `pro-tabs-mode` recomputes these faces from the current theme so startup and theme switches stay in sync.
  Proof: ERT plus manual theme refresh coverage.

- Name: Text Scale Isolation
  Stability: [FLUID]
  Spec: `text-scale-increase` and `face-remapping-alist` in the current buffer do not resize `tab-bar` or `tab-line`; pro-tabs keeps their height aligned to the frame default size.
  Proof: ERT coverage.

- Name: Tab-Line Rendering
  Stability: [FLUID]
  Spec: `pro-tabs-format-tab-line` and `pro-tabs-tabs-function-fast` cooperate to render buffers in the current window, while `pro-tabs-mode` leaves `tab-line-mode` under the user's control and only suppresses empty rows in buffers where tab-line is already enabled.
  Proof: `pro-tabs-e2e-test.el`.

- Name: Headless Test Runner
  Stability: [FROZEN]
  Spec: `nix flake check` runs the Emacs test suite headlessly via `pro-tabs.el`, `pro-tabs-test.el`, and `pro-tabs-e2e-test.el`.
  Proof: `flake.nix`.

- Name: Diagnostics Command
  Stability: [FLUID]
  Spec: `pro-tabs-diagnose` reports current tab-bar/tab-line state.
  Proof: manual use.

- Name: Runtime Controls
  Stability: [FLUID]
  Spec: `pro-tabs-refresh`, `pro-tabs-flush-caches`, `pro-tabs-repair-tab-line`, `pro-tabs-open-new-tab`, and `pro-tabs-close-tab-and-buffer` expose user-facing maintenance and action commands.
  Proof: command-level/manual coverage.

- Name: Debug Logging
  Stability: [FLUID]
  Spec: When `pro-tabs-debug-logging` is non-nil, icon/provider, cache, and render decisions are reported to `*Messages*`.
  Proof: manual use.

- Name: Format Cache
  Stability: [FLUID]
  Spec: `pro-tabs--format` logs cache hits and misses when debug logging is enabled.
  Proof: manual use.

- Name: Icon Providers
  Stability: [FLUID]
  Spec: `pro-tabs-icon-functions` resolves tab icons through an `all-the-icons` provider with a unicode bullet fallback when icons are unavailable.
  Proof: manual/e2e coverage.

- Name: Icon Cache Key
  Stability: [FLUID]
  Spec: Buffer icons are cached by buffer, backend, and active-state so current/inactive faces can differ correctly.
  Proof: manual/e2e coverage.

- Name: Mode-Aware Icons
  Stability: [FLUID]
  Spec: Buffer icon and tab string caches vary with `major-mode` so mode-specific icons update after a mode change.
  Proof: `pro-tabs-test.el`.

- Name: Cache Invalidation
  Stability: [FLUID]
  Spec: Buffer-list, window-selection, window-configuration changes, and pro-tabs mode toggles flush icon and format caches.
  Proof: manual/e2e coverage.
