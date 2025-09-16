{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      perSystem =
        { pkgs, lib, ... }:
        {
          treefmt = {
            projectRootFile = ".git/config";

            # Nix
            programs.nixfmt.enable = true;

            # Haskell
            programs.ormolu.enable = true;
            programs.hlint.enable = true;

            # Yaml
            programs.yamlfmt.enable = true;
            settings.formatter.yamlfmt.options = [
              "-conf"
              "./.yamlfmt.yml"
            ];

            # GitHub Actions
            programs.actionlint.enable = true;

            # Markdown
            programs.mdformat.enable = true;

            # ShellScript
            programs.shellcheck.enable = true;
            programs.shfmt.enable = true;
          };

          devShells.default =
            let
              add-grandpa-buildtools =
                drv:
                pkgs.haskell.lib.addBuildTools drv [
                  # Build tools
                  pkgs.haskellPackages.stack

                  # Linter
                  pkgs.haskellPackages.hlint

                  # LSP
                  pkgs.haskellPackages.haskell-language-server
                  pkgs.nil
                ];
              add-grandpa-pkgconfig-depends =
                drv:
                pkgs.haskell.lib.addPkgconfigDepends drv [
                  pkgs.SDL2
                ];
            in
            pkgs.haskellPackages.developPackage {
              root = ./.;
              modifier = drv: add-grandpa-buildtools (add-grandpa-pkgconfig-depends drv);
            };
        };
    };
}
