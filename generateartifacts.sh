
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
		
		$CONFIGTXGEN -profile sales -outputCreateChannelTx ./sales.tx -channelID sales
		
		echo "Generating anchor peers tx files for  Buyer"
		$CONFIGTXGEN -profile sales -outputAnchorPeersUpdate  ./salesBuyerMSPAnchor.tx -channelID sales -asOrg BuyerMSP
		
		echo "Generating anchor peers tx files for  Seller"
		$CONFIGTXGEN -profile sales -outputAnchorPeersUpdate  ./salesSellerMSPAnchor.tx -channelID sales -asOrg SellerMSP
		

		

}
function generateDockerComposeFile(){
	OPTS="-i"
	if [ "$ARCH" = "Darwin" ]; then
		OPTS="-it"
	fi
	cp  docker-compose-template.yaml  docker-compose.yaml
	
	
	cd  crypto-config/peerOrganizations/superbuyer.com/ca
	PRIV_KEY=$(ls *_sk)
	cd ../../../../
	sed $OPTS "s/BUYER_PRIVATE_KEY/${PRIV_KEY}/g"  docker-compose.yaml
	
	
	cd  crypto-config/peerOrganizations/rapidseller.net/ca
	PRIV_KEY=$(ls *_sk)
	cd ../../../../
	sed $OPTS "s/SELLER_PRIVATE_KEY/${PRIV_KEY}/g"  docker-compose.yaml
	
}
generateArtifacts 
cd $PWD
generateDockerComposeFile
cd $PWD


mkdir ca-buyer 
touch ca-buyer/fabric-ca-server.db


mkdir ca-seller 
touch ca-seller/fabric-ca-server.db


