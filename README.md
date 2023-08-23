# talos-proxmox-cluster

[![Terraform](https://github.com/Naman1997/talos-proxmox-cluster/actions/workflows/terraform.yml/badge.svg)](https://github.com/Naman1997/talos-proxmox-cluster/actions/workflows/terraform.yml)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/Naman1997/simple-fcos-cluster/blob/main/LICENSE)

Automated talos cluster with system extensions

## Dependencies

`Client` refers to the node that will be executing `terraform apply` to create the cluster. The `Raspberry Pi` can be replaced with a VM or a LXC container. The items marked `Optional` are needed only when you want to expose your kubernetes services to the internet via WireGuard.

| Dependency | Location |
| ------ | ------ |
| [Proxmox](https://www.proxmox.com/en/proxmox-ve) | Proxmox node |
| [xz](https://en.wikipedia.org/wiki/XZ_Utils) | Proxmox node |
| [jq](https://stedolan.github.io/jq/) | Client |
| [arp-scan](https://linux.die.net/man/1/arp-scan) | Client |
| [talosctl](https://www.talos.dev/latest/learn-more/talosctl/) | Client |
| [Terraform](https://www.terraform.io/) | Client |
| [HAproxy](http://www.haproxy.org/) | Raspberry Pi |
| [Wireguard](https://www.wireguard.com/) (Optional) | Raspberry Pi & Cloud VPS |
| [Docker](https://docs.docker.com/) (Optional) | Cloud VPS |
| [Docker](https://docs.docker.com/) | Client |

### Create an HA Proxy Server

I've installed `haproxy` on my Raspberry Pi. You can choose to do the same in a LXC container or a VM.

You need to have passwordless SSH access to a user (from the Client node) in this node which has the permissions to modify the file `/etc/haproxy/haproxy.cfg` and permissions to run `sudo systemctl restart haproxy`. An example is covered in this [doc](https://github.com/Naman1997/talos-proxmox-cluster/blob/main/docs/HA_Proxy.md).


### Create the terraform.tfvars file

The variables needed to configure this script are documented in this [doc](https://github.com/Naman1997/talos-proxmox-cluster/blob/main/docs/Variables.md).

```
cp terraform.tfvars.example terraform.tfvars
# Edit and save the variables according to your liking
vim terraform.tfvars
```


## Creating the cluster

```
terraform init -upgrade
terraform plan
# WARNING: The next command will override ~/.kube/config. Make a backup if needed.
terraform apply --auto-approve
```
