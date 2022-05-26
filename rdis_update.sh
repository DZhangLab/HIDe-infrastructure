
#!/bin/sh
export CHANNEL_NAME="rdis"
export CC_NAME="rdis"
export CC_VERSION="2.0"
export CC_SEQ=2

# Retrive last version 
. setpeer.sh  HospitalOrg peer0

peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME} >&clog.txt
export SEQ=$(tail -n 1 clog.txt | awk -F ',' '{ print $2 }'| awk -F ':' '{print $2}')
export NEWSEQ=$((SEQ+1))
export CC_VERSION="${NEWSEQ}.0"
export CC_SEQ=$NEWSEQ
echo "Going to upgrade ${CC_NAME} on ${CHANNEL_NAME} to version ${CC_VERSION} sequence ${CC_SEQ} "


. setpeer.sh  HospitalOrg peer0

# Package the chaincode 
cd chaincode/github.com/rdis
peer lifecycle chaincode package /opt/ws/${CC_NAME}.tar.gz  --path .  --lang golang --label ${CC_NAME}_${CC_VERSION}
cd /opt/ws



# Install the chaincode package 
. setpeer.sh HospitalOrg peer0
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
. setpeer.sh HospitalOrg peer1
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
. setpeer.sh HospitalOrg peer2
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
. setpeer.sh ClinicOrg peer0
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Install the chaincode package 
. setpeer.sh ClinicOrg peer1
peer lifecycle chaincode install ${CC_NAME}.tar.gz



# Approve Organization HospitalOrg 

. setpeer.sh HospitalOrg peer0
peer lifecycle chaincode queryinstalled >&cqHospitalOrglog.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" cqHospitalOrglog.txt)
echo $PACKAGE_ID
peer lifecycle chaincode approveformyorg -o orderer0.ordererOrg.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQ --init-required  --signature-policy "  OR( 'HospitalOrgMSP.member' , 'ClinicOrgMSP.member')  " 



# Approve Organization ClinicOrg 

. setpeer.sh ClinicOrg peer0
peer lifecycle chaincode queryinstalled >&cqClinicOrglog.txt
PACKAGE_ID=$(sed -n "/${CC_NAME}_${CC_VERSION}/{s/^Package ID: //; s/, Label:.*$//; p;}" cqClinicOrglog.txt)
echo $PACKAGE_ID
peer lifecycle chaincode approveformyorg -o orderer0.ordererOrg.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --package-id $PACKAGE_ID --sequence $CC_SEQ --init-required  --signature-policy "  OR( 'HospitalOrgMSP.member' , 'ClinicOrgMSP.member')  " 



#Commit chaincode installation 

export PEER_CONN=" --peerAddresses peer0.hospitalOrg.com:7051 --tlsRootCertFiles ${HOSPITALORG_PEER0_CA}  --peerAddresses peer0.clinicOrg.com:7051 --tlsRootCertFiles ${CLINICORG_PEER0_CA} "
peer lifecycle chaincode commit -o orderer0.ordererOrg.net:7050  --tls --cafile $ORDERER_CA --channelID $CHANNEL_NAME --name $CC_NAME --version $CC_VERSION --sequence $CC_SEQ --init-required --signature-policy "  OR( 'HospitalOrgMSP.member' , 'ClinicOrgMSP.member') " $PEER_CONN



#Query commited in Org HospitalOrg
. setpeer.sh HospitalOrg peer0
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}



#Query commited in Org ClinicOrg
. setpeer.sh ClinicOrg peer0
peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name ${CC_NAME}


sleep 2
#Invoke init
peer chaincode invoke -o orderer0.ordererOrg.net:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n ${CC_NAME} $PEER_CONN --isInit -c '{"Args":[""]}'


