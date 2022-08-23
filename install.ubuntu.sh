#!/bin/bash
set -e
set -o noglob

KOMPOSE_VERSION="v1.26.1"
clusterDNS="${clusterDNS}"
clusterDomain="${clusterDomain}"
K3S_TOKEN="${TOKEN}"


echo "Update APT repositories..."
apt-get update

echo "Verify that required packages are available..."
apt-get install -y curl cron-apt unattended-upgrades msmtp-mta gpg

# check if leader = true = 1
echo "----"
printenv
echo "----"
set -xv

if [ "$LEADER" = true ];
then
  #read -rp "Is there already a leader in place? [y/n]" r
  if [ "$K3S_CLUSTER_INIT" != true ];
  then
    # This section add additional leader server to an existing cluster
   #read -rp "What is the clusterDNS Name?" clusterDNS
   #read -rsp "What is the secret token?" TOKEN
   echo "Install k3s..."
   curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN sh -s - server --disable traefik --disable servicelb --server https://$clusterDNS:6443 --tls-san $clusterDNS
   echo "Check Nodes"
   kubectl get nodes
  else
  #
  # This section creates a new cluster
  #
  echo "Create Manifest folder"
  mkdir -p /var/lib/rancher/k3s/server/manifests
  echo "Add kube-vip DaemonSet RBAC manifest"
  curl https://kube-vip.io/manifests/rbac.yaml > /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml
  
  echo "Install k3s..."
  curl -sfL https://get.k3s.io | sh -s - server --cluster-init --tls-san $clusterDNS --cluster-domain $clusterDomain
   
  echo "Install helm..."
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm

  echo "Install kompose..."
  #curl -L https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64.deb -o kompose.deb
  #apt install ./kompose.deb
  #rm ./kompose.deb
  # Linux
  curl -L https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-linux-amd64 -o kompose
  chmod +x kompose
  sudo mv ./kompose /usr/local/bin/kompose
  
  echo "Install Longhorn"
  helm repo add longhorn https://charts.longhorn.io
  helm repo update
  helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
  kubectl -n longhorn-system get pod
  
  echo "Install falco"
  helm repo add falcosecurity https://falcosecurity.github.io/charts
  helm repo update
  helm install falco falcosecurity/falco --namespace falco --create-namespace
  
  fi
else
 echo "Configure an agent only..."
 #read -rp "What is the clusterDNS Name?" clusterDNS
 #read -rsp "What is the secret token?" TOKEN
 curl -sfL https://get.k3s.io | K3S_URL=https://$clusterDNS:6443 K3S_TOKEN=$K3S_TOKEN sh -
fi

echo "Update system..."
apt-get upgrade -y

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get all --all-namespaces
  


echo "Node installed and can now be configured."


