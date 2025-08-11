{ config, lib, pkgs, serverName, ... }@args:
let
  serverNum = lib.last (lib.splitString "-" serverName);
  serverConfig = args.serverConfig;
  defaultGateway = args.defaultGateway;
in
{
  imports = [ /etc/nixos/hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  networking.useDHCP = false;
  networking.bonds = (serverConfig.${serverName}.nicBinding or {
    bond0 = { interfaces = ["eno3" "eno4"]; };
    bond1 = { interfaces = ["eno1" "eno2"]; };
  });
  networking.interfaces.bond0.ipv4.addresses = [ {
    address = serverConfig.${serverName}.networking.address or "192.168.100.${serverNum}";
    prefixLength = 24;
  } ];
  networking.interfaces.bond1.ipv4.addresses = [ {
    address = "192.168.200.${serverNum}";
    prefixLength = 24;
  } ];
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];
  networking.defaultGateway = serverConfig.${serverName}.networking.defaultGateway or defaultGateway;
  networking.enableIPv6 = false;
  networking.hostName = serverName;
  networking.firewall.enable = false;

  services.openssh.enable = true;

  time.timeZone = "Asia/Singapore";
  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.05";
}
