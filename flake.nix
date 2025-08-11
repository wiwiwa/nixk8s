{
  description = "Kubernetes hosts configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  outputs = { self, nixpkgs, ... }@inputs:
  let
    defaultGateway = "192.168.100.254";
    serverConfig = {
      "brvx-dc-7" = {
        nicBinding = {
          bond0 = { interfaces = ["eno1" "eno2" "eno3" "eno4" ]; };
          bond1 = { interfaces = ["ens1f0" "ens1f1" ]; };
        };
	      k8s_master=true;
      };
      "brvx-dc-8" = { };
      "brvx-dc-9" = { };
      "qemu-7" = { # to test in qemu
        nicBinding = {
          bond0 = { interfaces = ["ens3"]; };
          bond1 = { interfaces = ["ens4"]; };
        };
        networking.address = "10.0.2.15";
        networking.defaultGateway = "10.0.2.2";
        k8s_master=true;
      };
    };

    makeSystem = serverName: nixpkgs.lib.nixosSystem rec{
      system = "x86_64-linux";
      specialArgs = { inherit serverConfig defaultGateway serverName; };
      modules = [
        ./nixos.nix
        ./users.nix
        ./k8s.nix
      ];
    };
    servers = with nixpkgs.lib; mapAttrs' (serverName: serverData: {
        name = serverName;
        value = makeSystem serverName;
      }) serverConfig;
  in {
    nixosConfigurations = servers;
  };
}
