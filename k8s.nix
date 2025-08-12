{ config, lib, pkgs, serverConfig, ... }@args:
let
  serverName = config.networking.hostName;
  masterList = lib.attrNames (lib.filterAttrs (n: v: v.k8s_master or false) serverConfig);
  masterName = lib.head masterList;
  masterNum = lib.last (lib.splitString "-" masterName);
  crictl = "${pkgs.cri-tools}/bin/crictl";
in {
  config = {
    services.kubernetes.roles =
      if (serverConfig.${serverName}.k8s_master or false)
      then [ "master" "node" ]
      else [ "node" ];
    services.kubernetes.masterAddress = "192.168.200.${masterNum}";
    services.kubernetes.flannel.enable = false;
    services.kubernetes.apiserver.allowPrivileged = true;
    services.kubernetes.kubelet.cni.packages = [ pkgs.cni-plugins ];
    # restart daemonset cilium to write /opt/cni/bin/cilium-cni, as kubelet service clear /opt/cni/bin when starting
    systemd.services.kubelet.postStart = ''
      mkdir -p /var/lib/kubelet/pods /var/lib/kubelet/plugins_registry
      id=$(${crictl} pods --label app.kubernetes.io/name=cilium-agent -q)
      ${crictl} stopp $id
      ${crictl} rmp $id
    '';
    environment.systemPackages = [ pkgs.kubectl pkgs.cilium-cli ];
    # make /etc/cni/net.d writtable
    fileSystems."/etc/cni/net.d" = {
      device = "/var/lib/kubelet";
      fsType = "none";
      options = [ "bind" ];
    };
    fileSystems."/lib/modules" = {
      device = "/run/booted-system/kernel-modules/lib/modules";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}
