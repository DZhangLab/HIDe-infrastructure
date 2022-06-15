
#!/bin/sh
export CHANNEL_NAME="sales"
export CC_NAME="salestrade"
export CC_VERSION="1.0"
export CC_SEQ=1

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=$PWD/config/

.setpeer.sh  Buyer peer0

# Package the chaincode 
# cd chaincode/github.com/salestrade
# peer lifecycle chaincode package /opt/ws/${CC_NAME}.tar.gz  --path .  --lang javascript --label ${CC_NAME}_${CC_VERSION}
peer lifecycle chaincode package ${CC_NAME}.tar.gz  --path ./chaincode/github.com/salestrade/  --lang node --label ${CC_NAME}_${CC_VERSION}

# cd /opt/ws
cd chaincode/github.com/salestrade/


# Install the chaincode package 
../../../setpeer.sh Buyer peer0
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
../../../setpeer.sh Buyer peer1
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
../../../setpeer.sh Seller peer0
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
../../../setpeer.sh Seller peer1
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Approve Organization Buyer 

../../../setpeer.sh Buyer peer0
peer lifecycle chaincode queryinstalled >&cqBuyerlog.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" cqBuyerlog.txt)
echo $PACKAGE_ID
peer lifecycle chaincode approveformyorg -o orderer0.orderer.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQ --init-required  --signature-policy "  OR( 'BuyerMSP.member' , 'SellerMSP.member')  " 



# Approve Organization Seller 

../../../setpeer.sh Seller peer0
peer lifecycle chaincode queryinstalled >&cqSellerlog.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" cqSellerlog.txt)
echo $PACKAGE_ID
peer lifecycle chaincode approveformyorg -o orderer0.orderer.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQ --init-required  --signature-policy "  OR( 'BuyerMSP.member' , 'SellerMSP.member')  " 



#Commit chaincode installation 

export PEER_CONN=" --peerAddresses peer0.superbuyer.com:7051 --tlsRootCertFiles ${BUYER_PEER0_CA}  --peerAddresses peer0.rapidseller.net:7051 --tlsRootCertFiles ${SELLER_PEER0_CA} "
peer lifecycle chaincode commit -o orderer0.orderer.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --sequence $CC_SEQ --init-required --signature-policy "  OR( 'BuyerMSP.member' , 'SellerMSP.member') " $PEER_CONN



#Query commited in Org Buyer
../../../setpeer.sh Buyer peer0
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}



#Query commited in Org Seller
../../../setpeer.sh Seller peer0
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}


sleep 2
#Invoke init
peer chaincode invoke -o orderer0.orderer.net:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN --isInit -c '{"Args":[""]}'


