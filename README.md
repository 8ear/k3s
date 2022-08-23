# k3s
Installer Scripts to Make a new node directly ready with k3s to join the cluster

## Usage
I use as base Image Ubuntu 22.04 LXC Container


1. Settings for the LXC Container:
- Uncheck unprivileged container
- In memory, set swap to 0

2. Modify container config
Now back on the host run pct list to determine what VMID it was given.
Open /etc/pve/lxc/$VMID.conf and append:
```bash
lxc.apparmor.profile: unconfined
lxc.cap.drop:
lxc.mount.auto: "proc:rw sys:rw"
lxc.cgroup2.devices.allow: c 10:200 rwm
```
3. start LXC container

4. Enable shared host mounts
From within the container, run:
```bash
echo '#!/bin/sh -e
ln -s /dev/console /dev/kmsg
mount --make-rshared /' > /etc/rc.local
chmod +x /etc/rc.local
reboot
```

5a. For a leader: 
```bash
export clusterDNS=<fix address where all cluster leader can be asked via DNS round robin or any else LB>
export clusterDomain=<domain suffix of cluster>
export K3S_TOKEN=<your k3s token>
# For a new cluster:
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER=true K3S_CLUSTER_INIT=true clusterDNS=$clusterDNS clusterDomain=$clusterDomain sh -
# To extend a existing cluster
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER=true clusterDNS=$clusterDNS K3S_TOKEN=$K3S_TOKEN sh -

```

5b.For a worker node:

```bash
export K3S_TOKEN=<your k3s token>
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | clusterDNS=$clusterDNS K3S_TOKEN=$K3S_TOKEN sh -
```

## Sources
- https://linuxize.com/post/wget-command-examples/
- https://rancher.com/docs/k3s/latest/en/installation/install-options/
- https://davegallant.ca/blog/2021/11/14/running-k3s-in-lxc-on-proxmox/
