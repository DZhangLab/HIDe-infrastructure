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

### Package the smart contract

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

4. Navigate back to ./test-network directory and add the binaries we installed at the beginning to utilize the peer CLI

```bash
cd ../../test-network
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
```

5. Create the chaincode package in the current directory (basic.tar.gz)

```bash
peer lifecycle chaincode package basic.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_1.0
```

### Install the chaincode

1. Export the following environment variables for org1

```bash
# Environment variables for Org1
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

2. Install the chaincode on peer1. On success, the peer will generate and return the package identifier

```bash
peer lifecycle chaincode install basic.tar.gz
```

3. Export the following environment variables for org2

```bash
# Environment variables for Org2

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

4. Install the chaincode on peer2. On success,

```bash
peer lifecycle chaincode install basic.tar.gz
```

### Approve a chaincode definition

1. Find the package ID of the chaincode

```bash
peer lifecycle chaincode queryinstalled
```

2. Save the package ID as an environment variable. The package ID is different for every user so be sure to paste your own package ID instead of the one below

```bash
export CC_PACKAGE_ID=basic_1.0:ee09716080838e1c287295df0f2c85ecf048b814932e478c14cc53a2615c5627
```

3. Approve the chaincode definition as org2

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

4. Set the following environment variables to operate as the Org1 admin

```bash
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051
```

5. Approve the chaincode definition as org1

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

```

### Committing the chaincode definition to the channel

1. Check whether channel members have approved the same chaincode definition

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

2. Since both organizations that are members of the channel have approved the same parameters, commit the chaincode definition to the channel

```bash
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"


```

3. Confirm that the chaincode definition has been committed to the channel

```bash
peer lifecycle chaincode querycommitted --channelID mychannel --name basic --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

- On success, output should be something like this
  ```bash
  Committed chaincode definition for chaincode 'basic' on channel 'mychannel':
  Version: 1.0, Sequence: 1, Endorsement Plugin: escc, Validation Plugin: vscc, Approvals: [Org1MSP: true, Org2MSP: true]
  ```

### Invoking the chaincode

1. Invoke the chaincode by creating an initial set of assets on the ledger

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'
```

2. Read the set of cars that were created by the chaincode

```bash
peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'
```

### Upgrading a smart contract

1. Set the environment variables needed to use the peer CLI and create another chaincode package in the current directory (basic.tar.gz)

```bash
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
peer lifecycle chaincode package basic_2.tar.gz --path ../asset-transfer-basic/chaincode-javascript/ --lang node --label basic_2.0
```

2. Set Environment variables to operate the peer as the Org1 admin

```bash
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051
```

3. Install the new chaincode package on the Org1 peer.

```bash
peer lifecycle chaincode install basic_2.tar.gz
```

4. Find the new package ID by querying our peer

```bash
peer lifecycle chaincode queryinstalled
```

- On success, output should be something like this
  ```bash
  Installed chaincodes on peer:
  Package ID: basic_2.0:c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b, Label: basic_2.0
  Package ID: basic_1.0:ee09716080838e1c287295df0f2c85ecf048b814932e478c14cc53a2615c5627, Label: basic_1.0
  ```

5. Save the new packae ID as a new environment variable. The package ID is different for every user so be sure to paste your own package ID instead of the one below

```bash
export NEW_CC_PACKAGE_ID=basic_2.0:c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b
```

6. Approve a new chaincode definition as Org1

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

7. Set Environment variables to operate the peer as the Org2 admin

```bash
export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051
```

8. Install the new chaincode package on the Org2 peer

```bash
peer lifecycle chaincode install basic_2.tar.gz
```

9. Approve the new chaincode definition for Org2

```bash
peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --package-id $NEW_CC_PACKAGE_ID --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
```

10. Check if the chaincode definition with sequence 2 is ready to be committed to the channel

```bash
peer lifecycle chaincode checkcommitreadiness --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --output json
```

11. Upgrade the chaincode for Org2

```bash
peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name basic --version 2.0 --sequence 2 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"
```

12. Verify that the new chaincode has started on your peers

```bash
docker ps
```

- On success, output should be something like this
  ```bash
  CONTAINER ID   IMAGE                                                                                                                                                                    COMMAND                  CREATED          STATUS          PORTS                                                                    NAMES
  0f7c11597adf   dev-peer0.org1.example.com-basic_2.0-c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b-a3ad3f4f232233ba9148c46e0ba39977e54a119d026b5d328f81188cecaf4dc0   "docker-entrypoint.s…"   29 seconds ago   Up 28 seconds                                                                            dev-peer0.org1.example.com-basic_2.0-c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b
  80a5cad4b0c9   dev-peer0.org2.example.com-basic_2.0-c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b-f2bdfa435c6cbf56eecdbf801d44d724f7bff2ee6ce032e5d4833a19840dd7d3   "docker-entrypoint.s…"   29 seconds ago   Up 29 seconds                                                                            dev-peer0.org2.example.com-basic_2.0-c522b9ca4df9be460b8136444b317ee77603613ef4de022b72b16c5de8080a9b
  30c3d67d01bd   hyperledger/fabric-tools:latest                                                                                                                                          "/bin/bash"              28 minutes ago   Up 28 minutes                                                                            cli
  6bcd5a8d38e6   hyperledger/fabric-peer:latest                                                                                                                                           "peer node start"        28 minutes ago   Up 28 minutes   0.0.0.0:7051->7051/tcp, 0.0.0.0:9444->9444/tcp                           peer0.org1.example.com
  631a606a256f   hyperledger/fabric-orderer:latest
  ```

13. Test the new JavaScript chaincode by creating a new car and then query all the cars on the ledger

```bash
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"CreateAsset","Args":["asset8","blue","16","Kelley","750"]}'

peer chaincode query -C mychannel -n basic -c '{"Args":["GetAllAssets"]}'

```

14. Clean up the network

```bash
./network.sh down
```

## Running a Fabric Application (WINDOWS)

1. Bring up a new network and create a new channel called mychannel

```bash
./network.sh up createChannel -c mychannel -ca
```

2. Deploy the chaincode package containing the TypeScript smart contract.

```bash
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-typescript/ -ccl typescript
```

3. Package the smart contract by installing the smart contract dependencies in the following directory

```bash
cd ../asset-transfer-basic/application-gateway-typescript

npm install
```

4. Start the sample application. Make sure to have the latest version of node installed

```bash
npm start
```

5. Clean up the network

```bash
./network.sh down
```
