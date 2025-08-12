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
    services.kubernetes.apiserver.allowPrivileged = true;
    services.kubernetes.kubelet.cni.packages = [ pkgs.cni-plugins ];
    # restart daemonset cilium to write /opt/cni/bin/cilium-cni, as kubelet service clear /opt/cni/bin when starting
    systemd.services.kubelet.postStart = ''
      export PATH=/nix/var/nix/profiles/system/sw/bin \
        KUBECONFIG=/etc/kubernetes/cluster-admin.kubeconfig
      kubectl -n kube-system get pod -o wide -l k8s-app=cilium | \
        awk "\$7==\"$(hostname)\"{print \$1}" | \
        xargs kubectl -n kube-system delete pod
    '';
    environment.systemPackages = [ pkgs.kubectl pkgs.cilium-cli ];
    # make /etc/cni/net.d writtable
    fileSystems."/etc/cni/net.d" = {
      device = "/var/lib/kubelet";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}
