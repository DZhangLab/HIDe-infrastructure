######
## Runs the Hyperleder Fabic Test Network, 
## and installs a sample chaincode and invokes it to test the network came up properly.
##
##      Usage: run this script in the fabric-samples/test-network folder
######

CHANNEL1_NAME=channel1

# add HL binaries to path
export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

# Start Hyperledger Fabric, and create channel
./network.sh up createChannel -c $CHANNEL1_NAME

##########################################################################################
# install chaincode
##########################################################################################
./network.sh deployCC -ccn basic -ccp ../asset-transfer-basic/chaincode-go -ccl go -c $CHANNEL1_NAME

##########################################################################################
# test chaincode
##########################################################################################

# As org:
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

## Invoke chaincode
peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" -C $CHANNEL1_NAME -n basic --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt" -c '{"function":"InitLedger","Args":[]}'

## Now query that:
peer chaincode query -C $CHANNEL1_NAME -n basic -c '{"Args":["GetAllAssets"]}'
