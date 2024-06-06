{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs = { self, flake-utils, opam-nix, nixpkgs }@inputs:
    # Don't forget to put the package name instead of `throw':
    let package = "twenty_fourty_eight"; 
    in flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        devPackagesQuery = {
          # You can add "development" packages here. They will get added to the devShell automatically.
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          utop = "*";
        };
        query = devPackagesQuery // {
          ## You can force versions of certain packages here, e.g:
          ## - force the ocaml compiler to be taken from opam-repository:
          ocaml-base-compiler = "*";
          ocaml-lsp-server = "*";
          ## - or force the compiler to be taken from nixpkgs and be a certain version:
          # ocaml-system = "4.14.0";
          ## - or force ocamlfind to be a certain version:
          # ocamlfind = "1.9.2";
        };
        
        overlay = final: prev: {
          # You can add overrides here
          ${package} = prev.${package}.overrideAttrs (_: {
            # Prevent the ocaml dependencies from leaking into dependent environments
            doNixSupport = false;
            removeOcamlReferences = true;
            postFixup = "rm -rf $out/nix-support";
          });
        };

        scope = on.buildOpamProject' { } ./. query;
        scope' = scope.overrideScope' overlay;
        main = scope'.${package};
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
        
        prdScope = on.buildOpamProject' { pkgs = pkgs.pkgsStatic; } ./. query;
        prdScope' = prdScope.overrideScope' overlay;
        # The main package containing the executable
        prd = prdScope'.${package};
        # Packages from devPackagesQuery
        prdPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) prdScope');
      in {
        legacyPackages = scope';

        packages = {
            default = main;
            prd = prd;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs = devPackages ++ [
            # You can add packages from nixpkgs here
          ]; 
        };
      });
}
