# Setting up EC2 for HL

## EC2 Specs
- Ubuntu (latest)
- Ram 8 GB
- t2.medium

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

Clone a repo called "fabric samples". This will install Fabric samples, docker images & binaries

```bash
curl -sSL https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/bootstrap.sh | bash -s
```


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

#### Add HyperLedger binaries to path
```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

### Start Hyperledger Fabric
- Move to the fabric test network directory

```bash
cd fabric-samples/test-network
```

- start hyper ledger fabric 

```
./network up 
```

- create channel 'mychannel'. 

```bash 
./network.sh createChannel
```

### Install chaincode

```bash
cd ../asset-transfer-basic/chaincode-javascript/
sudo apt install npm -y
```

### Add a peer to the Test Network

See [Adding a Peer](add-peer/README.md)
