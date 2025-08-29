{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "noteTree-dev";

  buildInputs = [
    pkgs.haskellPackages.ghc
    pkgs.haskellPackages.cabal-install
    pkgs.haskellPackages.threepenny-gui
    pkgs.haskellPackages.cmark
    pkgs.haskellPackages.text
    pkgs.haskellPackages.directory
    pkgs.haskellPackages.filepath
    pkgs.zlib
  ];

  shellHook = ''
    echo "Welcome to the noteTree dev shell!"
    echo "Run: cabal build && cabal run noteTree"
  '';
}
