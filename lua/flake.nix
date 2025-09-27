{
  # A helpful description of your flake
  description = "Flake template for lua projects";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # Flake outputs that other flakes can use
  outputs =
    { self, nixpkgs }:
    let
      # Helpers for producing system-specific outputs
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
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
              lua-language-server
              nixpkgs-fmt
            ];
          };
        }
      );
    };
}
