# AGENTS

## HDS Rules

- Treat `HOLO.md` and `SURFACE.md` as the project contract.
- Make one change per intent.
- If public behavior changes, update `SURFACE.md` first, then tests, then code.
- If a change touches a `[FROZEN]` surface, add or update proof.
- Keep core logic in Emacs Lisp pure where possible; keep side effects in `pro-tabs-mode`.

## Working Order

1. Surface
2. Proof
3. Code
4. Verify
5. Update `HOLO.md`

## Repo Notes

- The main implementation lives in `pro-tabs.el`.
- Integration coverage lives in `pro-tabs-test.el` and `pro-tabs-e2e-test.el`.
- `flake.nix` provides headless Emacs test execution.
- `pro-tabs-mode` must remain safe to enable/disable repeatedly.
- Avoid repo-specific shortcuts like OpenCode-only behavior.
- `SURFACE.md` and `HOLO.md` are the contract artifacts for HDS work.
- Keep icon-provider helpers small and composable when they grow too large.

## Verification

- Prefer ERT for proof and e2e checks.
- When possible, verify both enable/disable behavior and a rendering path.
- Keep `SURFACE.md` aligned with the shipped `flake.nix` and test files.

## HDS Boundary

- If a change alters a user-visible command, face, cache, or default, update `SURFACE.md` before code.
- If a change alters the runtime behavior story, update `HOLO.md` after verification.
