{
  description = "NixOS flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    defaultGateway = "192.168.100.1";
    serverConfig = {
      "brvx-dc-7" = {
        nicBinding = {
          bond0 = { interfaces = ["eno1" "eno2" "eno3" "eno4" ]; };
          bond1 = { interfaces = ["ens1f0" "ens1f1" ]; };
        };
      };
      "brvx-dc-8" = { };
      "brvx-dc-9" = { };
    };
    users = {
      users.samuel = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBroYELcc29VCobSL62jSZnNZIQq/UF8lFNYc1DktQk1OQnhb8H+2GQQmHhbUQjPkGiAhsWjHG9g4iM57qBCiYM= samuel@MBA-M2" ];
      };
      users.tom = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdDcq/wPcfPkESz8faqJ6/q+MrLkobZ7/ouCDqAsnSb azuread_omyang@HP-TY" ];
      };
    };

    makeSystem = serverName: serverNum: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { };
      modules = [ {
        inherit users;

        imports = [ /etc/nixos/hardware-configuration.nix ];
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        networking.useDHCP = false;
        networking.bonds = (serverConfig.${serverName}.nicBinding or {
          bond0 = { interfaces = ["eno3" "eno4"]; };
          bond1 = { interfaces = ["eno1" "eno2"]; };
        });
        networking.interfaces.bond0.ipv4.addresses = [ {
          address = "192.168.100.${serverNum}";
          prefixLength = 24;
        } ];
        networking.interfaces.bond1.ipv4.addresses = [ {
          address = "192.168.222.${serverNum}";
          prefixLength = 24;
        } ];
        networking.nameservers = ["1.1.1.1" "8.8.8.8"];
        networking.defaultGateway = defaultGateway;
        networking.hostName = serverName;

        services.openssh.enable = true;
        time.timeZone = "Asia/Singapore";
        environment.systemPackages = with nixpkgs.legacyPackages.${system}; [ vim ];
        security.sudo.wheelNeedsPassword = false;

        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        system.stateVersion = "25.05";
      } ];
    };
    servers = with nixpkgs.lib; mapAttrs' (serverName: serverData:
      let
        serverNum = last (splitString "-" serverName);
      in {
        name = serverName;
        value = makeSystem serverName serverNum;
      }) serverConfig;
  in {
    nixosConfigurations = servers;
  };
}
