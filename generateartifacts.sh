
#!/bin/bash -e
export PWD=`pwd`

export FABRIC_CFG_PATH=$PWD
export ARCH=$(uname -s)
export CRYPTOGEN=$PWD/bin/cryptogen
export CONFIGTXGEN=$PWD/bin/configtxgen

function generateArtifacts() {
	
	echo " *********** Generating artifacts ************ "
	echo " *********** Deleting old certificates ******* "
	
        rm -rf ./crypto-config
	
        echo " ************ Generating certificates ********* "
	
        $CRYPTOGEN generate --config=$FABRIC_CFG_PATH/crypto-config.yaml
        
        echo " ************ Generating tx files ************ "
	
		$CONFIGTXGEN -profile OrdererGenesis -channelID system-channel -outputBlock ./genesis.block
		
		$CONFIGTXGEN -profile rdis -outputCreateChannelTx ./rdis.tx -channelID rdis
		
		echo "Generating anchor peers tx files for  HospitalOrg"
		$CONFIGTXGEN -profile rdis -outputAnchorPeersUpdate  ./rdisHospitalOrgMSPAnchor.tx -channelID rdis -asOrg HospitalOrgMSP
		
		echo "Generating anchor peers tx files for  ClinicOrg"
		$CONFIGTXGEN -profile rdis -outputAnchorPeersUpdate  ./rdisClinicOrgMSPAnchor.tx -channelID rdis -asOrg ClinicOrgMSP
		

		

}
function generateDockerComposeFile(){
	OPTS="-i"
	if [ "$ARCH" = "Darwin" ]; then
		OPTS="-it"
	fi
	cp  docker-compose-template.yaml  docker-compose.yaml
	
	
	cd  crypto-config/peerOrganizations/hospitalOrg.com/ca
	PRIV_KEY=$(ls *_sk)
	cd ../../../../
	sed $OPTS "s/HOSPITALORG_PRIVATE_KEY/${PRIV_KEY}/g"  docker-compose.yaml
	
	
	cd  crypto-config/peerOrganizations/clinicOrg.com/ca
	PRIV_KEY=$(ls *_sk)
	cd ../../../../
	sed $OPTS "s/CLINICORG_PRIVATE_KEY/${PRIV_KEY}/g"  docker-compose.yaml
	
}
generateArtifacts 
cd $PWD
generateDockerComposeFile
cd $PWD


mkdir ca-hospitalorg 
touch ca-hospitalorg/fabric-ca-server.db


mkdir ca-clinicorg 
touch ca-clinicorg/fabric-ca-server.db


