{
  description = "TODO";
  inputs      = {
    nixpkgs.url     = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-darwin" ] (system:
      let
        packageName      = "inline-js-example";
        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));
        pkgs             = nixpkgs.legacyPackages.${system};
        # this and the 'override' below are from
        # https://github.com/tweag/inline-js/blob/master/README.md
        inline-js-src    = pkgs.fetchFromGitHub {
          owner  = "tweag";
          repo   = "inline-js";
          rev    = "8512b09d2c0533a41d5d2aef182b11a58c420c10";
          sha256 = "Hgiq8LJKLLpuMwmjlF3IeHTW2qBipMV6Q7up+mVKlVA=";
        };
        haskellPackages0 = pkgs.haskell.packages.ghc8107;
        haskellPackages  = haskellPackages0.override {
          overrides = self: _: {
            inline-js-core = (self.callCabal2nixWithOptions "inline-js-core" inline-js-src
              "--subpath inline-js-core"
              { }).overrideAttrs (_: {
                preBuild = ''
                  substituteInPlace src/Language/JavaScript/Inline/Core/NodePath.hs --replace '"node"' '"${pkgs.nodejs}/bin/node"'
                '';
              });
            inline-js =
              self.callCabal2nixWithOptions "inline-js" inline-js-src "--subpath inline-js" { };
          };
        };
      in {
        packages.${packageName} =
          haskellPackages.callCabal2nix packageName self rec {
            # Dependency overrides go here
          };
        defaultPackage          = self.packages.${system}.${packageName};
        devShell                = pkgs.mkShell {
          buildInputs = with haskellPackages; [
            cabal-install
            haskell-language-server
            hlint
            hpack
          ];
          inputsFrom            = builtins.attrValues self.packages.${system};
          shellHook             = "export PS1='\\e[1;34mnix shell> \\e[0m'";
        };
      });
}
