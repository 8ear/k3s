#!/bin/bash
KOMPOSE_VERSION="v1.26.1"

echo "Update APT repositories..."
#apt-get update

echo "Verify that required packages are available..."
#apt-get install -y curl cron-apt unattended-upgrades msmtp-mta

echo "Update system..."
#apt-get upgrade -y

# check if leader = true = 1
echo "$LEADER"
set -xv

if [ "$LEADER" = true ] ;
then
  read -erp "Is there already a leader in place? [y/n]" -i "y" r
  if [ "$r" = "y" ];
  then
   read -erp "What is the clusterDNS Name?" clusterDNS
   read -ersp "What is the secret token?" TOKEN
   echo "Install k3s..."
   curl -sfL https://get.k3s.io | K3S_TOKEN=$(TOKEN) sh -s - server --server https://$(clusterDNS):6443 --tls-san $(clusterDNS)
  fi
  
  echo "Check Nodes"
  kubectl get nodes
  exit 1
  
  echo "Install helm..."
  curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
  sudo apt-get install apt-transport-https --yes
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
  sudo apt-get update
  sudo apt-get install helm

  echo "Install kompose..."
  curl -L https://github.com/kubernetes/kompose/releases/download/${KOMPOSE_VERSION}/kompose-${KOMPOSE_VERSION}-amd64.deb -o kompose.deb
  apt install ./kompose.deb
  rm ./kompose.deb
  
else
 echo "Configure an agent only..."
 read -erp "What is the clusterDNS Name?" clusterDNS
 read -ersp "What is the secret token?" TOKEN
 curl -sfL https://get.k3s.io | K3S_URL=https://$(clusterDNS):6443 K3S_TOKEN=$(TOKEN) sh -
 
 
fi


echo "Node installed and can now be configured."
