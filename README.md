# NixOS Flake Configuration

This repository contains a NixOS configuration managed with Flakes.

## Usage

To apply the configuration to a host, use the `nixos-rebuild` command with the appropriate flake output.

### Example for a server

```sh
sudo nixos-rebuild switch --impure --flake https://github.com/wiwiwa/nixos-config/archive/refs/heads/main.tar.gz#brvx-dc-7
```

This will build the system configuration defined in `flake.nix` for the specified host and make it the current generation.
