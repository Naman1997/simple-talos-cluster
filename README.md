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
| [HAproxy](http://www.haproxy.org/) | Raspberry Pi |
| [Wireguard](https://www.wireguard.com/) (Optional) | Raspberry Pi & Cloud VPS |
| [Docker](https://docs.docker.com/) (Optional) | Cloud VPS |
| [Docker](https://docs.docker.com/) | Client |

`Client` refers to the node that will be executing `terraform apply` to create the cluster. The `Raspberry Pi` can be replaced with a VM or a LXC container. The items marked `Optional` are needed only when you want to expose your kubernetes services to the internet via WireGuard.

Docker is mandatory on the `Client` as this projects builds a custom talos image with system extensions using the [imager](https://github.com/siderolabs/talos/pkgs/container/installer) docker image on the `Client` itself.

## Create an HA Proxy Server

I've installed `haproxy` on my Raspberry Pi. You can choose to do the same in a LXC container or a VM.

You need to have passwordless SSH access to a user (from the Client node) in this node which has the permissions to modify the file `/etc/haproxy/haproxy.cfg` and permissions to run `sudo systemctl restart haproxy`. An example is covered in this [doc](docs/HA_Proxy.md).


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
# WARNING: The next command will override ~/.kube/config. Make a backup if needed.
terraform apply --auto-approve
```

## Using HAProxy as a Load Balancer for an Ingress

Since HAProxy is load-balancing ports 80 and 443 (of worker nodes), we can deploy nginx-controller such that it uses those ports as an external load balancer IP.

```
kubectl label ns ingress-nginx pod-security.kubernetes.io/enforce=privileged
# Update the IP address in the controller yaml
vim ./nginx-example/nginx-controller.yaml
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --values ./nginx-example/nginx-controller.yaml --create-namespace
kubectl create deployment nginx --image=nginx --replicas=5
k expose deploy nginx --port 80
# Edit this config to point to your domain
vim ./nginx-example/ingress.yaml.example
mv ./nginx-example/ingress.yaml.example ./nginx-example/ingress.yaml
k create -f ./nginx-example/ingress.yaml
curl -k https://192.168.0.101
```

## Exposing your cluster to the internet with a free subdomain! (Optional)

You'll need an account with duckdns - they provide you with a free subdomain that you can use to host your web services from your home internet. You'll also be needing a VPS in the cloud that can take in your traffic from a public IP address so that you don't expose your own IP address. Oracle provides a [free tier](https://www.oracle.com/in/cloud/free/) account with 4 vcpus and 24GB of memory. I'll be using this to create a VM. To expose the traffic properly, follow this [guide](docs/Wireguard_Setup.md).

For this setup, we'll be installing wireguard on the VPS and the node that is running haproxy. The traffic flow is shown in the image below.
