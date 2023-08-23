# Variables needed for terraform.tfvars file

| Variable | Description |
| ------ | ------ |
| system_type | System Type. Valid values: intel / amd |
| PROXMOX_API_ENDPOINT | API endpoint for proxmox |
| PROXMOX_USERNAME | User name used to login proxmox |
| PROXMOX_PASSWORD | Password used to login proxmox |
| PROXMOX_IP | IP address for proxmox |
| DEFAULT_BRIDGE | Bridge to use when creating VMs in proxmox |
| TARGET_NODE | Target node name in proxmox |
| MASTER_COUNT | Number of masters to create (Should be an odd number) |
| WORKER_COUNT | Number of workers to create |
| autostart | Enable/Disable VM start on host bootup |
| master_config | Kubernetes master config |
| worker_config | Kubernetes worker config |
| ha_proxy_server | IP address of server running haproxy |
| ha_proxy_user | User on ha_proxy_server that can modify '/etc/haproxy/haproxy.cfg' and restart haproxy.service |
