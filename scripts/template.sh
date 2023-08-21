qm destroy 8000
xz -v -d talos/talos.raw.xz
sleep 3
qm create 8000 --memory 2048 --net0 virtio,bridge=vmbr0 --agent 1 --cores 2 --sockets 1 --cpu cputype=x86-64-v2
qm importdisk 8000 talos/talos.raw local-lvm
qm set 8000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-8000-disk-0,cache=writeback,discard=on
qm set 8000 --boot c --bootdisk scsi0
qm resize 8000 scsi0 +20G
qm set 8000 --ipconfig0 ip=dhcp
qm set 8000 --name talos-golden --template 1
sleep 30 # Needed due to disk resize