{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    defaultGateway = "192.168.10.1";
    commonSystem = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { };
      modules = [ {
          imports = [ /etc/nixos/hardware-configuration.nix ];

          boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          networking.nameservers = ["1.1.1.1" "8.8.8.8"];
          networking.defaultGateway = defaultGateway;
	  networking.interfaces.eno1.ipv4.addresses = [ {
	    address = "192.168.100.7";
	    prefixLength = 23;
	  } ];

          services.openssh.enable = true;
	  time.timeZone = "Asia/Singapore";
          security.sudo.wheelNeedsPassword = false;
          users.users.samuel = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };
          environment.systemPackages = with nixpkgs.legacyPackages.${system}; [ vim ];
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          system.stateVersion = "25.05";
      } ];
    };
  in {
    nixosConfigurations = {
      server-7 = commonSystem;
    };
  };
}
