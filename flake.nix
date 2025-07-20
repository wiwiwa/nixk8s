{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    commonSystem = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { };
      modules = [
        ./configuration.nix
        { time.timeZone = "Asia/Singapore"; }
      ];
    };
  in {
    nixosConfigurations = {
      server7 = commonSystem;
      server8 = commonSystem;
    };
  };
}
