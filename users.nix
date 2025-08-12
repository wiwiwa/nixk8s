{ config, pkgs, lib, ... }:
{
  config = {
    users.users = {
      samuel = {
        isNormalUser = true;
        extraGroups = [ "wheel" "kubernetes" ];
        openssh.authorizedKeys.keys = [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBBroYELcc29VCobSL62jSZnNZIQq/UF8lFNYc1DktQk1OQnhb8H+2GQQmHhbUQjPkGiAhsWjHG9g4iM57qBCiYM= samuel@MBA-M2" ];
        shell = pkgs.zsh;
      };
      tom = {
        isNormalUser = true;
        extraGroups = [ "wheel" "kubernetes" ];
        openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdDcq/wPcfPkESz8faqJ6/q+MrLkobZ7/ouCDqAsnSb azuread_omyang@HP-TY" ];
      };
    };
  };
}