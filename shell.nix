let
  pkgs = import <nixpkgs> {
    overlays = [(import ./overlays.nix)];
  };
in
  with pkgs;
  mkShell {
    name = "mlShell";
    buildInputs = [
      clojure
      clj-kondo
      openjdk
    ];
  }
