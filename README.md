# blockchain-health-identity

## Prerequisites (WINDOWS)

### Install Dependencies

1. [Docker](https://docs.docker.com/get-docker/)
2. [WSL](https://docs.microsoft.com/en-us/windows/wsl/install)

- If installing for the first time

  ```bash
  wsl --install
  ```

  else install the Ubuntu Linux distribution

  ```bash
  wsl --install -d Ubuntu
  ```

- set the default verion to WSL 2
  ```bash
  wsl --set-default-version 2
  ```
- list your installed Linux distributions
  ```bash
  wsl -l -v
  ```
- set the default Linux distribution to Ubuntu
  ```bash
  wsl -s Ubuntu
  ```
- setup docker wsl integration (Docker Settings -> Resources -> WSL Integration). Over there, check the "WSL Integration" box. The WSL2 linux distribution (Ubuntu) should pop up. Check it and restart Docker

### Install Fabric and Fabric Samples

Clone a repo called "fabric samples". This will install Fabric samples, docker images & binaries

```bash
curl -sSL https://bit.ly/2ysbOFE | bash -s
```

## Using the Fabric test network (WINDOWS)

1. Navigate to the test-network folder

```bash
cd fabric-samples/test-network
```

2. Clean up any previously run containers before bringing up a new container (Good Practice!). This will create 2 peer nodes, one ordering node

- Peer nodes store the blockchain ledger and validate transactions by running the smart contracts
- Ordering nodes handle the order of transactions and add them to blocks which are distributed to peer nodes

```bash
./network.sh down
./network.sh up
```

- When trying to start a network, the following error might pop up

```bash
"Error response from daemon: mkdir C:\Program Files\Git\var: Access is denied."
```

### Solution

Reproduce the following steps for 2 directories

- C:\Users\\[username]\.docker
- C:\Program Files\Git

Right click the directory -> Properties -> Security -> Edit -> Add -> Type "users" in the text box -> Check Names -> Ok -> Highlight the newly added group and check "Full Control" under "Permissions" -> Apply -> Ok -> Ok

3.  To verify, list all running docker containers

```bash
docker ps -a
```

4. Create a channel ("mychannel" by default) to join the 2 peer nodes

```bash
./network.sh createChannel
```

5. Run chaincode (Go) on the channel. This chaincode is stored in the directory "../asset-transfer-basic/chaincode-go"

```bash
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go
```

### Interacting with the Network

1. Add the binaries to the CLI

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

2. Export the following environment variables for org1

```bash
# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

# Environment variables for Org2
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

3. Initialize the ledger with assets

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

2. Query the ledger to get the list of assets/a specific asset

```bash
  $ peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

  $ peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'
```

3. Change the owner of an asset on the ledger by invoking the chaincode

```bash
$ peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'
```
