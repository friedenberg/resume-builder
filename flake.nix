{
  description = "a justfile that takes a Pandoc-flavored markdown file and
  renders it as a resume in various formats";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/6d41bc27aaf7b6a3ba6b169db3bd5d6159cfaa47";
    nixpkgs-master.url = "github:NixOS/nixpkgs/5b7e21f22978c4b740b3907f3251b470f466a9a2";
    utils.url = "https://flakehub.com/f/numtide/flake-utils/0.1.102";
    devenv-pandoc.url = "github:amarbel-llc/eng?dir=devenvs/pandoc";
    # TODO update to dedicated repo
    html-to-pdf.url = "github:amarbel-llc/eng?dir=pkgs/alfa/html-to-pdf";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-master,
      utils,
      devenv-pandoc,
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
