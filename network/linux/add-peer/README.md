# Adding peers to Test Network 

## Overview 

This walks through how to add another peer to the Test Network. The overall steps are:

- Add peer for testing HA network config. Adding peers - add on existing network and join to existing channel 
- Adding peer1.org.example.com to Org1
- Generate crypto material (using Fabric CA; preferred over cryptogen)
- Create docker-compose file for peer  
- Join peer to existing channel (org-level)
- Install chaincode to peer (org-level)

These steps were taken from the blog [Add a Peer to an Organization in Test Network (Hyperledger Fabric v2.2)](https://kctheservant.medium.com/add-a-peer-to-an-organization-in-test-network-hyperledger-fabric-v2-2-4a08cb901c98)

## Steps

1. Open 2 terminals (for peer0.org1 and peer0.org2)

	Terminal 1: 

	```
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="Org1MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
	export CORE_PEER_ADDRESS=localhost:7051

	export PATH=$PATH:$PWD/../bin/

	export FABRIC_CFG_PATH=$PWD/../config/
	export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
	```

	Terminal 2:

	```
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="Org2MSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
	export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
	export CORE_PEER_ADDRESS=localhost:9051

	export PATH=$PATH:$PWD/../bin/

	export FABRIC_CFG_PATH=$PWD/../config/
	export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
	```







1. Bring up the Test Network:
	
		cd fabric-samples/test-network
		./network.sh up createChannel -ca


	There should now be 6 containers are running:
	- 3 CAs, one for each org
	- 1 orderer 
	- 2 peers, one for Org1 and one for Org2 




ON EACH ORG? (yes for query)


1. Deploy chaincode SACC using network/sh:

		./network.sh up deployCC —ccn mycc —ccp ../chaincode/sacc -ccl go

	Look at the output of service discovery about endorsement. We see endorsing policy requires both organizations, and each organization has one peer currently

1. Test chaincode - Invoke from from org1:

		peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $ORDERER_CA -C mychannel -n mycc --peerAddresses localhost:7051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["set","name","Alice"]}'
		

1. Test chaincode - run query from both orgs (terminals):

		peer chaincode query -C mychannel -n mycc -c ‘{“Args”:[“get”,“name”]}’

1. Generate crypto material for new peer from org1 CA

		Run `HIDe-infrastructure/network/linux/add-peer/register-peer.sh` (based on ./organizations/fabric-ca/registerEnroll.sh)

1. Check the directory structure for peer1.org1.example.com. We see the msp/ directory structure, and the three files required in tls/, that is, ca.crt, server.crt and server.key

		ls -l organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/

1. Create configuration for the new peer and bring up the container

	Use the docker compose file adapted from `docker-compose-test-net.yaml`, with updated host, directory and port for peer1.

		docker-compose -f ~/HIDe-infrastructure/network/linux/add-peer/docker/docker-compose-test-net-peer1.yaml up -d

	Check to see the peer1 container is up with `docker ps`

1. Join the new peer to the existing channel

	We are accessing both peer0.org1.example.com and peer1.org1.example.com with the same terminal for Org1. To specify peer1.org1.example.com, we set the variable CORE_PEER_ADDRESS=localhost:8051 before any peer commands.

	First, let’s check the channel both peers of Org1 have joined.

		peer channel list
		CORE_PEER_ADDRESS=localhost:8051 peer channel list

	To join the channel, we need the channel genesis block. It was generated during channel creation when we first executed the ./network.sh script, and the block file is kept in channel-artifacts/mychannel.block.

		CORE_PEER_ADDRESS=localhost:8051 peer channel join -b channel-artifacts/mychannel.block

	Now we see it has joined the channel and should have a copy of the ledger from the other peers:

		peer channel list
		peer channel getinfo -c mychannel 
		CORE_PEER_ADDRESS=localhost:8051 peer channel getinfo -c mychannel
	
	All 3 peers should have a copy of the ledger now. 

1. Install chaincode to new peer 

	First check if we can use peer1.org1.example.com in chaincode query. We will see we can't, because a chaincode is not installed:

		peer chaincode query -C mychannel -n mycc -c '{"Args":["get","name"]}'
		CORE_PEER_ADDRESS=localhost:8051 peer chaincode query -C mychannel -n mycc -c '{"Args":["get","name"]}'

	We should a container for each peer now (2), and their images:

		docker ps --filter="name=dev"
		docker images dev*

	Install chaincode from package & check it appears:

		CORE_PEER_ADDRESS=localhost:8051 peer lifecycle chaincode install mycc.tar.gz

		docker ps --filter"name=dev"

	Look on the service discovery on endorsement, now we have two peers for Org1. Either one is good enough to handle the endorsement for Org1. We will test this in the next step (servicediscovery_testnetwork_p1o1.json).

1. Test chaincode using new peer 

	Query  state of an existing asset from peer1.org1 and ensure a result (i.e. Alice):

		peer chaincode query -C mychannel -n mycc -c '{"Args":["get","name"]}'
		CORE_PEER_ADDRESS=localhost:8051 peer chaincode query -C mychannel -n mycc -c '{"Args":["get","name"]}'

	Invoke an action with peer1.org1 as an endorser from org1 (default is majority, so will need another):

		peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --tls true --cafile $ORDERER_CA -C mychannel -n mycc --peerAddresses localhost:8051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt --peerAddresses localhost:9051 --tlsRootCertFiles ${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt -c '{"Args":["set","name","Bob"]}'

	You should see a success message. Now query the result from all peers:
		
		CORE_PEER_ADDRESS=localhost:7051 peer chaincode query -C mychannel -n mycc -c ‘{“Args”:[“get”,“name”]}’
		CORE_PEER_ADDRESS=localhost:8051 peer chaincode query -C mychannel -n mycc -c ‘{“Args”:[“get”,“name”]}’
		CORE_PEER_ADDRESS=localhost:9051 peer chaincode query -C mychannel -n mycc -c ‘{“Args”:[“get”,“name”]}’

	