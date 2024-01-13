# talos-proxmox-cluster

[![Terraform](https://github.com/Naman1997/talos-proxmox-cluster/actions/workflows/terraform.yml/badge.svg)](https://github.com/Naman1997/talos-proxmox-cluster/actions/workflows/terraform.yml)
[![GitHub license](https://img.shields.io/github/license/Naereen/StrapDown.js.svg)](https://github.com/Naman1997/talos-proxmox-cluster/blob/main/LICENSE)

Automated talos cluster with system extensions

## Dependencies

| Dependency | Location |
| ------ | ------ |
| [Proxmox](https://www.proxmox.com/en/proxmox-ve) | Proxmox node |
| [xz](https://en.wikipedia.org/wiki/XZ_Utils) | Proxmox node |
| [jq](https://stedolan.github.io/jq/) | Client |
| [arp-scan](https://linux.die.net/man/1/arp-scan) | Client |
| [talosctl](https://www.talos.dev/latest/learn-more/talosctl/) | Client |
| [Terraform](https://www.terraform.io/) | Client |
| [Docker](https://docs.docker.com/) | Client |

`Client` refers to the node that will be executing `terraform apply` to create the cluster.

Docker is mandatory on the `Client` as this projects builds a custom talos image with system extensions using the [imager](https://github.com/siderolabs/talos/pkgs/container/installer) docker image on the `Client` itself.


## Create the terraform.tfvars file

The variables needed to configure this script are documented in this [doc](docs/Variables.md).

```
cp terraform.tfvars.example terraform.tfvars
# Edit and save the variables according to your liking
vim terraform.tfvars
```


## Creating the cluster

```
terraform init -upgrade
terraform plan
terraform apply --auto-approve
```

## Notes
- This branch does not include an external load-balancer to simplify setup. In case you need an external load-balancer, consider using the [main](https://github.com/Naman1997/simple-talos-cluster/tree/main) branch.

## Expose your cluster to the internet (Optional)

It is possible to expose your cluster to the internet over a small vps even if both your vps and your public ips are dynamic. This is possible by setting up dynamic dns for the vps using something like duckdns and a docker container to regularly monitor the IP addresse of the VPS. A connection can be then made using wireguard to traverse the network between these 2 nodes. This way you can hide your public IP while exposing services to the internet.

Project Link: [wireguard-k8s-lb](https://github.com/Naman1997/wireguard-k8s-lb)