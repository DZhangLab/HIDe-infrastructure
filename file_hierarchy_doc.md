# blockchain-health-identity
## File Hierarchy

```
|   bin (DO NOT CHANGE)   
|___config - Configuration Files for fabric (DO NOT CHANGE)
|   |   configtx.yaml - sample config file for channel configuration (NOT the actual config)
|   |   core.yaml - sample peer configuration file
|   |   orderer.yaml - orderer configuration file used for creating a channel
|___test-network - Primary folder for setting up our network
|   |___compose - Docker configuration
|   |   |___docker
|   |   |   |___peercfg
|   |   |   |   |   core.yaml - peer configuration file (DO NOT CHANGE)
|   |   |   |   docker-compose-ca.yaml - Docker container configuration for CA certificates,
|   |   |   |   docker-compose-couch.yaml - Docker container configuration for couchDB
|   |   |   |   docker-compose-test-net.yaml - Docker container configuration for test network
|   |   |   compose-ca.yaml - Base container configuration for CA certificates
|   |   |   compose-couch.yaml - Base container configuration for couchDB
|   |   |   compose-test-net.yaml - Base container configuration for test network
|   |___configtx - Actual configuration for channel creation utilized by the configtxgen tool
|   |   |   configtx.yaml - Config file utilized by the configtxgen tool. This creates our .block file in ../channel-artifacts folder
|   |___organizations - All organizational materials (crypto materials, certificates etc.)
|   |   |___cryptogen
|   |   |   |   crypto-config-orderer.yaml - file used to create crypto material (org identity) using cryptogen
|   |   |   |   crypto-config-org1.yaml
|   |   |   |   crypto-config-org2.yaml
|   |   |   ccp-generate.sh - generates Org Certificate files (tlsca & ca) in organizations/peerOrganizations && ordererOrganizations
|   |   |   ccp-template.json - json template for ccp generation
|   |   |   ccp-template.yaml - yaml template for ccp generation
|   |___scripts - helper utility scripts called within the main script (./network.sh) and other scripts
|   |   |   ccutils.sh - utility functions for chaincode operations such as quering, commit, invoke etc.
|   |   |   configUpdate.sh - fetching, creating, and signing config update
|   |   |   createChannel.sh - creation of genesis block, creation and joining of channel, and setting anchor peers
|   |   |   deployCC.sh - packaging and deployment of chaincode
|   |   |   envVar.sh - Sets global environment variables to be used in other scripts
|   |   |   setAnchorPeer.sh - creation and update of Anchor Peer into the channel
|   |   |   utils.sh - prints usage for certain commands
|   |   network.sh - primary script for utilizing network
|   |   setOrgEnv.sh - utility script to set Environment Variables for organization identity
```



