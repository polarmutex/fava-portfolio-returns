{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix";
  #inputs.polar-nur.url = "github:polarmutex/nur";

  outputs = { self, nixpkgs, flake-utils, poetry2nix, polar-nur }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            self.overlay
            #polar-nur.overlays.default
          ];
        };
      in
      {
        devShell =
          let
            fava_portfolio_env = pkgs.poetry2nix.mkPoetryEnv {
              projectDir = ./.;
              editablePackageSources = {
                fava_portfolio_returns = ./fava_portfolio_returns;
              };
              overrides = pkgs.poetry2nix.overrides.withDefaults (
                self: super: {
                  numpy = pkgs.python39.pkgs.numpy;
                  python-magic = pkgs.python39.pkgs.python-magic;
                  fava-porfolio-returns = super.fava-portfolio-returns.overridePythonAttrs (old: {
                    buildInputs = old.buildInputs or [ ] ++ [
                      self.poetry
                    ];
                  });
                  beangrow = super.beangrow.overridePythonAttrs (old: {
                    buildInputs = old.buildInputs or [ ] ++ [
                      self.poetry
                    ];
                  });
                }
              );
            };
          in
          pkgs.mkShell {
            buildInputs = [
              fava_portfolio_env
              pkgs.poetry
            ];
          };
      }));
}
