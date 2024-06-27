{
  description = "Developer Shell for Homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    checks = forAllSystems (system: {
      pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          check-merge-conflicts.enable = true;
          check-added-large-files.enable = true;

          end-of-file-fixer.enable = true;
          check-toml.enable = true;
          markdownlint.enable = true;

          trim-trailing-whitespace.enable = true;
          cspell = {
            enable = true;
          };

          yamllint.enable = true;
          yamlfmt.enable = true;
          pre-commit-hook-ensure-sops.enable = true;
        };
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;

        shellHook = ''
          export KUBECONFIG=~/.kube/config.personal
          ${self.checks.${system}.pre-commit-check.shellHook}
        '';

        packages = with nixpkgs.legacyPackages.${system}; [
          fluxcd
          kubernetes-helm
          kompose
          k9s
          kubectl
          sops

          go-task
          mkdocs
          python311Packages.mkdocs-material
        ];
      };
    });
  };
}
