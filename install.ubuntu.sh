#!/bin/sh
KOMPOSE_VERSION="v1.26.1"


echo "Update APT repositories..."
apt-get update

echo "Verify that required packages are available..."
apt-get install -y curl

echo "Install k3s..."
curl -sfL https://get.k3s.io | sh -

echo "Update system..."
apt-get upgrade -y

 if "$1" == "lead";
 then
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
fi

echo "Node installed and can now be configured."
