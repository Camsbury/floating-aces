let
  nixPinned =
  import (builtins.fetchTarball
  "https://github.com/NixOS/nixpkgs/archive/420f89ceb26.tar.gz") {};
in
  { nixpkgs ? nixPinned }:
  nixpkgs.pkgs.haskellPackages.callCabal2nix "floating-aces" ./. {}
