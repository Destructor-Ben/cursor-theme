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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./overlay.nix)
          ];
        };
      in
      {
        packages.default = pkgs.catppuccin-cursors;
        packages.personal = pkgs.catppuccin-cursors.mochaDark;

        formatter = pkgs.nixfmt-tree;
      }
    );
}
