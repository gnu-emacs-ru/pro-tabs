# SURFACE

- Name: Mode Toggle
  Stability: [FROZEN]
  Spec: `pro-tabs-mode` enables/disables the package without leaving tab-bar/tab-line unusable.
  Proof: `pro-tabs-test.el` enable/disable test.

- Name: Tab-Bar Rendering
  Stability: [FLUID]
  Spec: `pro-tabs-format-tab-bar` returns formatted tab strings for `tab-bar`.
  Proof: manual/e2e coverage.

- Name: Tab-Line Rendering
  Stability: [FLUID]
  Spec: `pro-tabs-format-tab-line` and `pro-tabs-tabs-function-fast` cooperate to render buffers in the current window.
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
  Spec: `pro-tabs-icon-functions` resolves tab icons through ordered providers with an `all-the-icons` provider and unicode fallback glyphs when icons are unavailable.
  Proof: manual/e2e coverage.

- Name: Icon Cache Key
  Stability: [FLUID]
  Spec: Buffer icons are cached by buffer, backend, and active-state so current/inactive faces can differ correctly.
  Proof: manual/e2e coverage.
