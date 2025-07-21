# NixOS Flake Configuration

This repository contains a NixOS configuration managed with Flakes.

## Usage

To apply the configuration to a host, use the `nixos-rebuild` command with the appropriate flake output.

This flake generates configurations for hosts named `brvx-dc-1` through `brvx-dc-254`.

### Example for a server

Replace `<hostname>` with the actual hostname of the server you are provisioning (e.g., `brvx-dc-1`).

```sh
sudo nixos-rebuild switch --flake --impure .#<hostname>
```

This will build the system configuration defined in `flake.nix` for the specified host and make it the current generation.
