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

3. Install [Git](https://git-scm.com/downloads)

- Update the following git configurations

```bash
git config --global core.autocrlf false
git config --global core.longpaths true
```

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

5. Run chaincode (JavaScript) on the channel. This chaincode is stored in the directory "../asset-transfer-basic/chaincode-javascript"

```bash
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-javascript -ccl javascript
```

- The Go Chaincode has issues with versioning. So a switch to the JavaScript Chaincode was made. More details [here](https://stackoverflow.com/questions/65224577/error-deploying-chaincode-in-hyperledger-fabric-2)!

### Interacting with the Network

1. Add the binaries we installed at the beginning to the CLI

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

2. Export the following environment variables for org1 and org2

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

3. Initialize the ledger with an initial list of assets. This will invoke the "InitLedger" function of the JavaScript chaincode

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

2. Query the ledger to get the list of assets/a specific asset

```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

peer chaincode query -C mychannel -n basic -c '{"Args":["ReadAsset","asset6"]}'
```

3. Change the owner of an asset on the ledger by invoking the chaincode function "TransferAsset"

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"TransferAsset","Args":["asset6","Christopher"]}'
```

4. Bring down the network

```bash
./network.sh down
```

## Deploying a smart contract to a channel (WINDOWS)

1. Start the network

```bash
./network.sh up
```

2. Create a channel

```bash
./network.sh createChannel
```

3. Package the smart contract by installing the smart contract dependencies in the following directory

```bash
cd ../asset-transfer-basic/chaincode-javascript

npm install
```

4. navigate back to ./test-network directory and add the binaries we installed at the beginning to utilize the peer CLI

```bash
cd ../../test-network
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

5. Create the chaincode package in the current directory (basic.tar.gz)

```bash
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_1.0
```

6. Export the following environment variables for org1

```bash
# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

7. Install the chaincode on peer1. On success, the peer will generate and return the package identifier

```bash
peer lifecycle chaincode install basic.tar.gz
```

8. Export the following environment variables for org2

```bash
# Environment variables for Org2

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

9. Install the chaincode on peer2. On success,

```bash
peer lifecycle chaincode install basic.tar.gz
```

10. Find the package ID of the chaincode

```bash
peer lifecycle chaincode queryinstalled
```

11. Save the package ID as an environment variable. The package ID is different for every user so be sure to paste your own package ID instead of the one below

```bash
export CC_PACKAGE_ID=basic_1.0:ee09716080838e1c287295df0f2c85ecf048b814932e478c14cc53a2615c5627
```

12. Approve the chaincode definition as org2

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

13. Set the following environment variables to operate as the Org1 admin

```bash
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
```

14. Approve the chaincode definition as org1

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

```

15. Check whether channel members have approved the same chaincode definition

```bash
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json
```

- On success, output should be something like this

  ```bash
  {
    "Approvals": {
        "Org1MSP": true,
        "Org2MSP": true
    }
  }
  ```

16. Since both organizations that are members of the channel have approved the same parameters, commit the chaincode definition to the channel

```bash
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"


```

17. Confirm that the chaincode definition has been committed to the channel

```bash
peer lifecycle chaincode querycommitted --channelID mychannel --name basic --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

- On success, output should be something like this
  ```bash
  Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
  Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
  ```

18.
