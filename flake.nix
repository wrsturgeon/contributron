{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils?shallow=1";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable?shallow=1";
    rust-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:oxalica/rust-overlay?shallow=1";
    };
    treefmt-nix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:numtide/treefmt-nix?shallow=1";
    };
  };
  outputs =
    {
      flake-utils,
      nixpkgs,
      rust-overlay,
      self,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        treefmt = treefmt-nix.lib.evalModule pkgs ./.treefmt.nix;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            rust
          ]
          ++ (with pkgs; [
            openssl
            pkg-config
          ]);
          RUST_BACKTRACE = "1";
        };
        formatter = treefmt.config.build.wrapper;
      }
    );
}
