{
  # A helpful description of your flake
  description = "Flake template for rust project";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    rust-overlay = {
      url = "https://flakehub.com/f/oxalica/rust-overlay/0.1.*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake outputs that other flakes can use
  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      # Nixpkgs overlays
      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          rustToolchain = final.rust-bin.stable.latest.default.override { extensions = [ "rust-src" ]; };
        })
      ];

      # Helpers for producing system-specific outputs
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit overlays system; };
          }
        );
    in
    {
      # Development environments
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            # Pinned packages available in the environment
            packages = with pkgs; [
              rustToolchain
              rust-analyzer
              nixpkgs-fmt
            ];

            # Environment variables
            env = {
              RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
            };
          };
        }
      );

      # Build command
      packages = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = builtins.baseNameOf self.outPath;
            src = self;
            cargoLock = {
              lockFile = ./Cargo.lock;
            };
          };
        }
      );

    };
}
