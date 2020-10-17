let
  nixPinned = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/420f89ceb26.tar.gz") {};
in
  { nixpkgs ? nixPinned }:
  let
    floatingAces = (import ./default.nix { inherit nixpkgs; });
    floatingAcesShell = with nixpkgs;
      haskell.lib.overrideCabal floatingAces (oldAttrs: {
        librarySystemDepends = with pkgs; [
          cabal-install
          haskellPackages.ghcid
          sourceHighlight
        ];
      });
  in
    floatingAcesShell.env
