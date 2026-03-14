{
  description = "a justfile that takes a Pandoc-flavored markdown file and
  renders it as a resume in various formats";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/3e20095fe3c6cbb1ddcef89b26969a69a1570776";
    nixpkgs-master.url = "github:NixOS/nixpkgs/e034e386767a6d00b65ac951821835bd977a08f7";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
    html-to-pdf.url = "github:amarbel-llc/html-to-pdf";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      utils,
      html-to-pdf,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        name = "resume-builder";

        buildInputs = with pkgs; [
          pandoc
          just
          html-to-pdf
        ];

        resume-builder = (pkgs.writeScriptBin name (builtins.readFile ./justfile)).overrideAttrs (old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        # to include all the templates and styles
        src = ./.;

      in
      rec {
        defaultPackage = packages.resume-builder;
        packages.resume-builder = pkgs.symlinkJoin {
          name = name;
          paths = [
            resume-builder
            src
          ]
          ++ buildInputs;

          buildInputs = [ pkgs.makeWrapper ];
          postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        };

        devShells.default = pkgs.mkShell {
          packages = (
            with pkgs;
            [
              pandoc
              just
              html-to-pdf.packages.${system}.html-to-pdf
              resume-builder
            ]
          );

          inputsFrom = [ ];
        };
      }
    );
}
