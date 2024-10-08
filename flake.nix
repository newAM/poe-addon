{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    interactive-html-bom = {
      url = "github:newam/interactive-html-bom-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    interactive-html-bom,
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    bom-pkg = interactive-html-bom.packages.x86_64-linux.default;
  in {
    packages.x86_64-linux.bom = pkgs.stdenv.mkDerivation {
      name = "bom";

      src = ./poe-addon.kicad_pcb;

      dontUnpack = true;

      buildPhase = ''
        mkdir $out
        export HOME=$(mktemp -d)

        ${bom-pkg}/bin/generate_interactive_bom $src \
          --extra-data-file $src \
          --no-browser \
          --dark-mode \
          --show-fields 'Value,DigiKey Part Number' \
          --group-fields 'DigiKey Part Number' \
          --dest-dir $out \
          --name-format index
      '';

      dontInstall = true;
    };

    checks.x86_64-linux.bom = self.packages.x86_64-linux.bom;
  };
}
