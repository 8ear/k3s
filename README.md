# k3s
Installer Scripts to Make a new node directly ready with k3s to join the cluster

## Usage
I use as base Image Ubuntu 22.04 LXC Container

For a leader: 
```bash
export clusterDNS=<fix address where all cluster leader can be asked via DNS round robin or any else LB>
export clusterDomain=<domain suffix of cluster>
export K3S_TOKEN=<your k3s token>
# For a new cluster:
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER= K3S_CLUSTER_INIT= clusterDNS=$clusterDNS clusterDomain=$clusterDomain K3S_TOKEN=$K3S_TOKEN sh -
# To extend a existing cluster
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER= clusterDNS=$clusterDNS K3S_TOKEN=$K3S_TOKEN sh -

```

For a worker node:

```bash
export K3S_TOKEN=<your k3s token>
wget -q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | clusterDNS=$clusterDNS K3S_TOKEN=$K3S_TOKEN sh -
```

## Sources
- https://linuxize.com/post/wget-command-examples/
- https://rancher.com/docs/k3s/latest/en/installation/install-options/
