# Setting up Hyperledger Fabric Test Network on EC2

## EC2 Specs
- Ubuntu (latest)
- Ram 8 GB
- t2.medium

## Outline of the steps

- Install dependencies and download Hyperledger Test Network files
- Run Hyperledger Fabric test network via docker compose. It comes with 2 peers and 1 orderer, and a channel, run by 2 organizations:

        - peer0.org1
        - peer0.org2


- Install a chaincode on the all peers and then a channel
- Invoke the chaincode and check the results

# Installing HL
## Option 1: Run the script 
The easiest and quickest way to set everything up is to run this script 
```bash
sh install-hyperledger-ubuntu.sh 
```

## Option 2: Installing manually

### Install Dependencies 

1. Install [Docker](https://docs.docker.com/get-docker/)

- http stuff needed for allowing egress https (i.e. talking to image registry)
```bash
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

- install docker

```bash
sudo apt-get update
```
```
sudo mkdir -p /etc/apt/keyrings
```
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

```bash
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo docker run hello-world

sudo apt install docker-compose -y
```

### Download & install Hyperledger Fabric binaries and samples

See this reference, [Using the Fabric test network](https://hyperledger-fabric.readthedocs.io/en/release-2.5/test_network.html)

Run this script. It will clone a repo called "fabric-samples" docker images & binaries, and samples (https://hyperledger-fabric.readthedocs.io/en/release-2.5/install.html)

```bash
$ mkdir -p $HOME/go/src/github.com/<your_github_userid>
$ cd $HOME/go/src/github.com/<your_github_userid>
$ curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
$ ./install-fabric.sh d s b
```

Add the fabric binaries to your path
export PATH="/Users/wyn/dev/DZhengLab/fabric/bin:$PATH"

(Note, setting this can be helpful in lieu of about FABRIC_CA_SERVER_HOME=${HOME}/fabric-ca/server)

<!-- 2.4.7
```bash
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s
``` -->

### Add username (ubuntu by default) to the docker group

- Create the docker group.

```bash
sudo groupadd docker
```

- Add your user to the docker group.

```bash
 sudo usermod -aG docker $USER
```

- Log out and log back in so that your group membership is re-evaluated.

- You can also run the following command to activate the changes to groups:

```bash
newgrp docker
```

- Verify that you can run docker commands without sudo.

``` bash
docker run hello-world
```

### Start Hyperledger Fabric
- Move to the fabric test network directory

```bash
cd fabric-samples/test-network
```

- start hyper ledger fabric 

```
./network.sh up -ca
```

- create channel

```bash 
./network.sh createChannel -c channel1
```

### Install a chaincode

- deployCC will install it on peer0.org1.example.com and peer0.org2.example.com 
- then will deploy it on the channel specified using the channel flag (or mychannel if no channel is specified)

```bash
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -c channel1
```

### Add Hyperledger binaries to path

The peer CLI allows you to invoke deployed smart contracts, update channels, or install and deploy new smart contracts from the CLI. The binaries are in the bin folder of the fabric-samples repository. Use the following command to add them to your path, as well as config path:

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

### Invoke a chaincode 

Set yourself as an org to use:

```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

The CORE_PEER_TLS_ROOTCERT_FILE and CORE_PEER_MSPCONFIGPATH environment variables point to the Org1 crypto material in the organizations folder.

Run the following command to initialize the ledger with assets:

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C channel1 -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

Now query that:

```
peer chaincode query -C channel1 -n basic -c '{"Args":["GetAllAssets"]}'
```

## Add a peer to the Test Network

See [Adding a Peer](add-peer/README.md)
