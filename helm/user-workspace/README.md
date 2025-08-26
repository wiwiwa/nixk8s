# Workspace

Manage workspaces for users by YAML.
* User configurations are defined in value `users`.
* Each workspace can be connected by VNC over SSH
* Each workspace runs in a lightweight VM

```bash
# create workspaces
$ helm install user-workspace ./helm/user-workspace
# add/remove/update workspaces
$ helm upgrade user-workspace ./helm/user-workspace
```
