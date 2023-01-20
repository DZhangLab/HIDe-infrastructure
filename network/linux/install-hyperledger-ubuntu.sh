#!/bin/bash
#
# Running this script will install and test Hyperledger Fabric and its dependencies using apt-get, curl and git
#
#   REF: https://github.com/DZhangLab/HIDe-infrastructure/tree/main/network/README.md

##########################################################################################
# install Docker Engine on Ubuntu. https://docs.docker.com/engine/install/ubuntu/
##########################################################################################

# http stuff needed for allowing egress https (i.e. talking to image registry)
sudo apt-get update
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

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world

sudo apt-get install docker-compose 

##########################################################################################
# download & install Hyperledger Fabric 
##########################################################################################

sudo chmod 666 /var/run/docker.sock
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s

# TODO: Need? add my username (ubuntu) to the docker group via: sudo usermod -aG docker ubuntu

# add HL binaries to path
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

git clone https://github.com/DZhangLab/HIDe-infrastructure

cd HIDe-infrastructure/network

# start Hyperledger Fabric
./network up 

# create channel 'mychannel'. Can use `-c <channel name>` 
./network.sh createChannel

##########################################################################################
# get samples & install chaincode
##########################################################################################

git clone fabric-samples
cd fabric-samples/asset-transfer-basic/chaincode-javascript/
sudo apt-get install npm

##########################################################################################
# test some ledger operations 
##########################################################################################

# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Invoke the chaincode by creating an initial set of assets on the ledger
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

# query the test data
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

# Switch to a different org 
# Environment variables for Org2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

# query the test data
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
