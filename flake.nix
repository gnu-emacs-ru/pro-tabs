{
  description = "pro-tabs development and test flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: builtins.listToAttrs (map (system: {
        name = system;
        value = f system;
      }) systems);
    in
    {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.emacs-nox;
        });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = [ pkgs.emacs-nox ];
          };
        });

      checks = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          tests = pkgs.runCommand "pro-tabs-tests" {
            nativeBuildInputs = [ pkgs.emacs-nox ];
          } ''
            export HOME="$TMPDIR"
            emacs --batch -Q -L ${self} \
              -l pro-tabs.el \
              -l pro-tabs-test.el \
              -l pro-tabs-e2e-test.el \
              -f ert-run-tests-batch-and-exit
            touch "$out"
          '';
        });
    };
}