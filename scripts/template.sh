BOOTDISK=scsi0
qm destroy 8000 || true
xz -v -d talos/talos.raw.xz
sleep 3
qm create 8000 --memory 2048 --net0 virtio,bridge=vmbr0 --agent 1 --cores 2 --sockets 1 --cpu cputype=x86-64-v2
qm importdisk 8000 talos/talos.raw local-lvm
qm set 8000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-8000-disk-0,cache=writeback,discard=on
qm set 8000 --boot c --bootdisk $BOOTDISK
qm resize 8000 $BOOTDISK +20G
qm set 8000 --ipconfig0 ip=dhcp
qm set 8000 --bios ovmf
qm set 8000 -efidisk0 local-lvm:0,format=raw,efitype=4m,pre-enrolled-keys=0
qm set 8000 --name talos-golden --template 1

# Make sure vmid exists
sleep 10
while ! qm config 8000 >/dev/null 2>&1; do
  sleep 5
done

# Make sure disk resize happened
qm=$(qm config 8000 | grep "$BOOTDISK" | cut -d "," -f 4 | cut -d "=" -f 2 | sed s/"M"// | tail -1)
while [ "$qm" -lt 20000 ]; do
  qm=$(qm config 8000 | grep "$BOOTDISK" | cut -d "," -f 4 | cut -d "=" -f 2 | sed s/"M"// | tail -1)
  sleep 5
done