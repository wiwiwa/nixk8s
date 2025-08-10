{ config, lib, pkgs, serverConfig, ... }@args:
let
  serverName = config.networking.hostName;
  masterNum = let
    masterList = lib.attrNames (lib.filterAttrs (n: v: v.k8s_master or false) serverConfig);
    masterName = lib.head masterList;
    in lib.last (lib.splitString "-" masterName);
in
{
  config = {
    services.kubernetes.roles =
      if (serverConfig.${serverName}.k8s_master or false)
      then [ "master" "node" ]
      else [ "node" ];
    services.kubernetes.masterAddress = "192.168.200.${masterNum}";
    services.kubernetes.flannel.enable = false;
  };
}
