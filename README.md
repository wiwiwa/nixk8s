# NixOS Flake Configuration

This repository contains a NixOS configuration managed with Flakes, which  prepare kubernetes master and worker nodes

## Usage

To apply the configuration to a host, use the `nixos-rebuild` command with the appropriate flake output.

### Example for a server

```sh
sudo nixos-rebuild switch --impure --flake https://github.com/wiwiwa/nixk8s/archive/refs/heads/main.tar.gz#brvx-dc-7
```

This will build the system configuration defined in `flake.nix` for the specified host

### Install Cilium

After master host is ready, install CNI plugin as following:
```sh
# check all services are ready before proceed
$ systemctl
$ cilium install
$ cilium status --wait
$ systemctl restart kubelet
```

### Install Ceph

```sh
$ cd manifests
# create ceph operator
$ kubectl create -f ceph-crds.yaml -f ceph-common.yaml -f ceph-operator.yaml
# verify the rook-ceph-operator is in the `Running` state before proceeding
$ kubectl -n rook-ceph get pod
# create ceph cluster
$ kubectl create -f ceph-cluster.yaml
# create ceph storage pool and storage class
$ kubectl create -f ceph-storage-class.yaml
```
