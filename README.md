# k3s
Installer Scripts to Make a new node directly ready with k3s to join the cluster

## Usage
For a leader: 
`wget-q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER=YES sh -`

For a worker node:
`wget-q -O - https://raw.githubusercontent.com/8ear/k3s/main/install.ubuntu.sh | LEADER=NO sh -`
