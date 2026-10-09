{
  description = "Pastel cursor theme with thick borders and rounded edges";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.callPackage (import ./.) {};
        packages.personal = (pkgs.callPackage (import ./.) { onlyBuildPersonal = true; }).mochaDark;

        formatter = pkgs.nixfmt-tree;
      }
    );
}
