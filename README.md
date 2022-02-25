# blockchain-health-identity

Everything is done by cloning a repo called "fabric samples" via the following command

```bash
$ curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.2.2 1.4.9
```

Clean up any previously run containers and bring up a new container

```bash
$ ./network.sh down
$ ./network.sh up
```

List all running docker containers

```bash
$ docker ps -a
```

Create a channel called channel1

```bash
$ ./network.sh createChannel -c channel1
```

Run chaincode on the channel

```bash
$ ./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go
```

## Interacting with the Network

1. Initialize the ledger with assets

```bash
$ peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile ${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem -C mychannel -n basic --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"function":"InitLedger","Args":[]}'
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
