#!/bin/bash
#
# Running this script will install and test Hyperledger Fabric and its dependencies using apt-get, curl and git
#
#   REF: https://github.com/DZhangLab/HIDe-infrastructure/tree/main/network/README.md
set -x 

##########################################################################################
# install Docker Engine via apt-get (https://docs.docker.com/engine/install/ubuntu/)
##########################################################################################
set -x # show commands before executing them

# http stuff needed for allowing egress https (i.e. talking to image registry)
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# install docker
sudo apt-get update
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo chmod a+r /etc/apt/keyrings/docker.gpg

sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo docker run hello-world

sudo apt install docker-compose -y

sudo chmod 666 /var/run/docker.sock

##########################################################################################
# Download & install Hyperledger Fabric binaries and samples:
#   - Clones the hyperledger/fabric-samples repository
#   - Downloads the latest Hyperledger Fabric Docker images and tags them as latest
#   - Downloads the following platform-specific Hyperledger Fabric CLI tool binaries and config files into the fabric-samples /bin and /config directories. 
#     These binaries will help you interact with the test network.
##########################################################################################
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s

# Add my username (ubuntu) to the docker group (note, this was not needed in all experiements)
sudo usermod -aG docker ubuntu

# add HL binaries to path
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

cd fabric-samples/test-network

# start Hyperledger Fabric
./network up 

# create channel 'mychannel'. Can use `-c <channel name>` 
./network.sh createChannel

##########################################################################################
# install chaincode
##########################################################################################

cd ../asset-transfer-basic/chaincode-javascript/
sudo apt install npm -y
